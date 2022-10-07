# Testing task
## How run
1. Install docker engine https://docs.docker.com/engine/install/
2. Copy (clone) project of this service
3. If need then change parameters (user name, user password, database name) for Grafana and PostgreSQL in `grafana.env` and `postgres.env`
4. Open console and switch to root directory of this service
5. For create and start service execute
```
docker-compose up -d
```
6. For stop and remove service execute
```
docker-compose down
```
