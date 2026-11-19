#!/usr/bin/env bash
set -euo pipefail

PROJECT="hw3_check_$$_$(date +%s)"
PORT="${TEST_PORT:-18080}"
BASE_URL="http://127.0.0.1:${PORT}"
N=3
BACKUP_DIR="$(pwd)/.tmp_backup_${PROJECT}"
BACKUP_FILE="${BACKUP_DIR}/redis_backup.tar.gz"
STAGE="init"

fail() {
  echo "[FAIL] Stage '${STAGE}': $1" >&2
  exit 1
}

cleanup() {
  docker compose -p "${PROJECT}" down -v --remove-orphans >/dev/null 2>&1 || true
  rm -rf "${BACKUP_DIR}"
}
trap cleanup EXIT

wait_ready() {
  local timeout=30
  local elapsed=0
  while [ "${elapsed}" -lt "${timeout}" ]; do
    if curl -fsS --max-time 2 "${BASE_URL}/readyz" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
    elapsed=$((elapsed + 1))
  done
  fail "service did not become ready within ${timeout}s"
}

check_count() {
  local expected="$1"
  local body
  body="$(curl -fsS --max-time 3 "${BASE_URL}/")" || fail "GET / failed"
  echo "${body}" | grep -Eq "\"count\":[[:space:]]*${expected}([^0-9]|$)" \
    || fail "expected count=${expected}, got: ${body}"
}

check_status() {
  local method="$1"
  local path="$2"
  local expected="$3"
  local code
  code="$(curl -sS --max-time 10 -o /dev/null -w "%{http_code}" -X "${method}" "${BASE_URL}${path}")" \
    || fail "${method} ${path} request failed"
  [ "${code}" = "${expected}" ] || fail "${method} ${path} expected HTTP ${expected}, got ${code}"
}

STAGE="1_start_clean_project"
echo "[STEP] ${STAGE}"
APP_PORT="${PORT}" docker compose -p "${PROJECT}" up -d --build
wait_ready

STAGE="2_initial_and_increments"
echo "[STEP] ${STAGE}"
check_count 0
for _ in $(seq 1 "${N}"); do
  curl -fsS --max-time 3 -X POST "${BASE_URL}/increment" >/dev/null || fail "POST /increment failed"
done
check_count "${N}"

STAGE="3_recreate_app"
echo "[STEP] ${STAGE}"
APP_PORT="${PORT}" docker compose -p "${PROJECT}" up -d --force-recreate --no-deps app
wait_ready
check_count "${N}"

STAGE="4_redis_stop_and_start"
echo "[STEP] ${STAGE}"
docker compose -p "${PROJECT}" stop redis
check_status GET /healthz 200
check_status GET /readyz 503
check_status POST /increment 503

docker compose -p "${PROJECT}" start redis
wait_ready
check_count "${N}"
curl -fsS --max-time 3 -X POST "${BASE_URL}/increment" >/dev/null || fail "POST /increment after recovery failed"
check_count "$((N + 1))"

STAGE="5_backup_redis_volume"
echo "[STEP] ${STAGE}"
docker compose -p "${PROJECT}" stop app redis
mkdir -p "${BACKUP_DIR}"
MSYS_NO_PATHCONV=1 docker run --rm \
  -v "${PROJECT}_redis_data:/data:ro" \
  alpine tar -czpf - -C /data . > "${BACKUP_FILE}"
[ -s "${BACKUP_FILE}" ] || fail "backup archive is empty or missing"
echo "[OK] Backup created: ${BACKUP_FILE}"

STAGE="6_cleanup_down_v"
echo "[STEP] ${STAGE}"
docker compose -p "${PROJECT}" down -v --remove-orphans

echo "[SUCCESS] All checks passed!"