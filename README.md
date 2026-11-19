# ДЗ по Docker

## Настройки Compose

`.env`: `APP_PORT` (порт на хосте, по умолчанию `8080` -> `8000` в контейнере), `GREETING`
`app`: `STORAGE=redis`, `REDIS_URL=redis://redis:6379/0`, `read_only: true`, `mem_limit: 256m`, `cpus: 1.0`, healthcheck `/healthz`, `depends_on` -> `redis` (`service_healthy`)
`redis`: `redis:7.4-alpine`, без публикации порта, `--appendonly yes`, volume `redis_data` -> `/data`, healthcheck `redis-cli ping`

## Запуск

```sh
cp .env.example .env
docker compose up -d --build
```

Остановка:
```sh
docker compose down
```

Автопроверка:
```sh
./scripts/check.sh
```

### 4 балла

```text
2026-11-19 16:46:39,959 listening port=8000 storage=sqlite
2026-11-19 16:48:47,397 http 172.17.0.1 "GET / HTTP/1.1" 200 -
2026-11-19 16:48:47,795 http 172.17.0.1 "POST /increment HTTP/1.1" 200 -
2026-11-19 16:48:48,195 http 172.17.0.1 "POST /increment HTTP/1.1" 200 -
```

### 6 баллов 

```text
(.venv) PS C:\Users\loper\VSCode\hw_3_template> docker compose up -d --build
[+] up 4/4
 ✔ Image hw_3_template-app       Built                                                                                 4.4s
 ✔ Network hw_3_template_default Created                                                                               0.1s
 ✔ Volume hw_3_template_app_data Created                                                                               0.0s
 ✔ Container hw_3_template-app-1 Started                                                                               0.7s
(.venv) PS C:\Users\loper\VSCode\hw_3_template> curl.exe -fsS -X POST [http://127.0.0.1:8080/increment](http://127.0.0.1:8080/increment)
{"greeting": "Hello from Compose!", "count": 1, "hostname": "fce40bda58f3", "storage": "sqlite"}
(.venv) PS C:\Users\loper\VSCode\hw_3_template> curl.exe -fsS -X POST [http://127.0.0.1:8080/increment](http://127.0.0.1:8080/increment)
{"greeting": "Hello from Compose!", "count": 2, "hostname": "fce40bda58f3", "storage": "sqlite"}
(.venv) PS C:\Users\loper\VSCode\hw_3_template> docker compose down
[+] down 2/2
 ✔ Container hw_3_template-app-1 Removed                                                                               3.4s
 ✔ Network hw_3_template_default Removed                                                                               0.3s
(.venv) PS C:\Users\loper\VSCode\hw_3_template> docker compose up -d
[+] up 2/2
 ✔ Network hw_3_template_default Created                                                                               0.1s
 ✔ Container hw_3_template-app-1 Started                                                                               0.7s
(.venv) PS C:\Users\loper\VSCode\hw_3_template> curl.exe -fsS [http://127.0.0.1:8080/](http://127.0.0.1:8080/)
{"greeting": "Hello from Compose!", "count": 2, "hostname": "a34491cce59a", "storage": "sqlite"}
```

### 8 баллов

```text
(.venv) PS C:\Users\loper\VSCode\hw_3_template> docker compose up -d
[+] up 4/4
 ✔ Network hw_3_template_default   Created                                                                             0.1s
 ✔ Volume hw_3_template_redis_data Created                                                                             0.0s
 ✔ Container hw_3_template-redis-1 Healthy                                                                             4.3s
 ✔ Container hw_3_template-app-1   Started                                                                             4.6s
(.venv) PS C:\Users\loper\VSCode\hw_3_template> curl.exe -fsS -X POST [http://127.0.0.1:8080/increment](http://127.0.0.1:8080/increment)
{"greeting": "Hello from Compose!", "count": 1, "hostname": "bc5ba3165484", "storage": "redis"}
(.venv) PS C:\Users\loper\VSCode\hw_3_template> curl.exe -fsS -X POST [http://127.0.0.1:8080/increment](http://127.0.0.1:8080/increment)
{"greeting": "Hello from Compose!", "count": 2, "hostname": "bc5ba3165484", "storage": "redis"}
(.venv) PS C:\Users\loper\VSCode\hw_3_template> docker compose down
[+] down 3/3
 ✔ Container hw_3_template-app-1   Removed                                                                             3.6s
 ✔ Container hw_3_template-redis-1 Removed                                                                             0.5s
 ✔ Network hw_3_template_default   Removed                                                                             0.3s
(.venv) PS C:\Users\loper\VSCode\hw_3_template> docker compose up -d
[+] up 3/3
 ✔ Network hw_3_template_default   Created                                                                             0.1s
 ✔ Container hw_3_template-redis-1 Healthy                                                                             4.3s
 ✔ Container hw_3_template-app-1   Started                                                                             4.6s
(.venv) PS C:\Users\loper\VSCode\hw_3_template> curl.exe -fsS [http://127.0.0.1:8080/](http://127.0.0.1:8080/)
{"greeting": "Hello from Compose!", "count": 2, "hostname": "255039e20bef", "storage": "redis"}
(.venv) PS C:\Users\loper\VSCode\hw_3_template> docker compose stop redis
[+] stop 1/1
 ✔ Container hw_3_template-redis-1 Stopped                                                                             0.5s
(.venv) PS C:\Users\loper\VSCode\hw_3_template> curl.exe -i [http://127.0.0.1:8080/healthz](http://127.0.0.1:8080/healthz)
HTTP/1.0 200 OK
Server: BaseHTTP/0.6 Python/3.13.18
Date: Thu, 19 Nov 2026 17:12:46 GMT
Content-Type: application/json; charset=utf-8
Content-Length: 19
Cache-Control: no-store
{"status": "alive"}
(.venv) PS C:\Users\loper\VSCode\hw_3_template> curl.exe -i [http://127.0.0.1:8080/readyz](http://127.0.0.1:8080/readyz)
HTTP/1.0 503 Service Unavailable
Server: BaseHTTP/0.6 Python/3.13.18
Date: Thu, 19 Nov 2026 17:12:54 GMT
Content-Type: application/json; charset=utf-8
Content-Length: 32
Cache-Control: no-store
{"error": "storage_unavailable"}
(.venv) PS C:\Users\loper\VSCode\hw_3_template> curl.exe -i -X POST [http://127.0.0.1:8080/increment](http://127.0.0.1:8080/increment)
HTTP/1.0 503 Service Unavailable
Server: BaseHTTP/0.6 Python/3.13.18
Date: Thu, 19 Nov 2026 17:13:03 GMT
Content-Type: application/json; charset=utf-8
Content-Length: 32
Cache-Control: no-store
{"error": "storage_unavailable"}
(.venv) PS C:\Users\loper\VSCode\hw_3_template> docker compose start redis
[+] start 1/1
 ✔ Container hw_3_template-redis-1 Started                                                                             0.3s
(.venv) PS C:\Users\loper\VSCode\hw_3_template> curl.exe -fsS [http://127.0.0.1:8080/](http://127.0.0.1:8080/)
{"greeting": "Hello from Compose!", "count": 2, "hostname": "255039e20bef", "storage": "redis"}
(.venv) PS C:\Users\loper\VSCode\hw_3_template> curl.exe -fsS -X POST [http://127.0.0.1:8080/increment](http://127.0.0.1:8080/increment)
{"greeting": "Hello from Compose!", "count": 3, "hostname": "255039e20bef", "storage": "redis"}
```

### 10 баллов

```text
loper@AsusVivobook MINGW64 ~/VSCode/hw_3_template (main)
$ ./scripts/check.sh
[STEP] 1_start_clean_project
[+] up 5/5
 ✔ Image hw3_check_1409_1795109429-app         Built                                                                   4.2s
 ✔ Network hw3_check_1409_1795109429_default   Created                                                                 0.2s
 ✔ Volume hw3_check_1409_1795109429_redis_data Created                                                                 0.1s
 ✔ Container hw3_check_1409_1795109429-redis-1 Healthy                                                                 4.6s
 ✔ Container hw3_check_1409_1795109429-app-1   Started                                                                 4.9s
[STEP] 2_initial_and_increments
[STEP] 3_recreate_app
[+] up 1/1
 ✔ Container hw3_check_1409_1795109429-app-1 Started                                                                   4.6s
[STEP] 4_redis_stop_and_start
[+] stop 1/1
 ✔ Container hw3_check_1409_1795109429-redis-1 Stopped                                                                 0.6s
[+] start 1/1
 ✔ Container hw3_check_1409_1795109429-redis-1 Started                                                                 0.4s
[STEP] 5_backup_redis_volume
[+] stop 2/2
 ✔ Container hw3_check_1409_1795109429-app-1   Stopped                                                                 3.7s
 ✔ Container hw3_check_1409_1795109429-redis-1 Stopped                                                                 0.5s
[OK] Backup created: /c/Users/loper/VSCode/hw_3_template/.tmp_backup_hw3_check_1409_1795109429/redis_backup.tar.gz
[STEP] 6_cleanup_down_v
[+] down 4/4
 ✔ Container hw3_check_1409_1795109429-redis-1 Removed                                                                 0.1s
 ✔ Container hw3_check_1409_1795109429-app-1   Removed                                                                 0.1s
 ✔ Network hw3_check_1409_1795109429_default   Removed                                                                 0.3s
 ✔ Volume hw3_check_1409_1795109429_redis_data Removed                                                                 0.1s
[SUCCESS] All checks passed!
```

```text
loper@AsusVivobook MINGW64 ~/VSCode/hw_3_template (main)
$ ./scripts/check.sh
[STEP] 1_start_clean_project
[+] up 5/5
 ✔ Image hw3_check_1484_1795109500-app         Built                                                                   4.0s
 ✔ Network hw3_check_1484_1795109500_default   Created                                                                 0.2s
 ✔ Volume hw3_check_1484_1795109500_redis_data Created                                                                 0.1s
 ✔ Container hw3_check_1484_1795109500-redis-1 Healthy                                                                 4.4s
 ✔ Container hw3_check_1484_1795109500-app-1   Started                                                                 4.7s
[STEP] 2_initial_and_increments
[STEP] 3_recreate_app
[+] up 1/1
 ✔ Container hw3_check_1484_1795109500-app-1 Started                                                                   4.8s
[STEP] 4_redis_stop_and_start
[+] stop 1/1
 ✔ Container hw3_check_1484_1795109500-redis-1 Stopped                                                                 0.7s
[+] start 1/1
 ✔ Container hw3_check_1484_1795109500-redis-1 Started                                                                 0.5s
[STEP] 5_backup_redis_volume
[+] stop 2/2
 ✔ Container hw3_check_1484_1795109500-app-1   Stopped                                                                 3.6s
 ✔ Container hw3_check_1484_1795109500-redis-1 Stopped                                                                 0.6s
[OK] Backup created: /c/Users/loper/VSCode/hw_3_template/.tmp_backup_hw3_check_1484_1795109500/redis_backup.tar.gz
[STEP] 6_cleanup_down_v
[+] down 4/4
 ✔ Container hw3_check_1484_1795109500-redis-1 Removed                                                                 0.1s
 ✔ Container hw3_check_1484_1795109500-app-1   Removed                                                                 0.1s
 ✔ Network hw3_check_1484_1795109500_default   Removed                                                                 0.3s
 ✔ Volume hw3_check_1484_1795109500_redis_data Removed                                                                 0.1s
[SUCCESS] All checks passed!
```