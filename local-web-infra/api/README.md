docker build -t localwebinfa-api .
docker logs --tail 50 api

export DATABASE_URL="mysql://root@host.docker.internal:3306/scorecardnotes"
export REDIS_URL="redis://host.docker.internal:6379"
