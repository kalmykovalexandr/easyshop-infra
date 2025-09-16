# EasyShop – Quick Deployment Guide

## Prerequisites
- Docker + Docker Compose (plugin) installed
- Git, Java 21 (JDK), Maven 3.9+

## First Deploy
1) Create env file from example:
   - `cp easyshop-infra/.env.example easyshop-infra/.env`
2) Make the deploy script executable and run it:
   - `chmod +x easyshop-infra/deploy.sh`
   - `./easyshop-infra/deploy.sh`

The script will pull latest changes, build all backend jars with Maven, then build and start containers with Docker Compose.

## Redeploy After Changes
- Simply run: `./easyshop-infra/deploy.sh`

## Useful Commands
- Status: `docker compose -f easyshop-infra/docker-compose.yml ps`
- Logs (follow): `docker compose -f easyshop-infra/docker-compose.yml logs -f api-gateway`
- Stop all: `docker compose -f easyshop-infra/docker-compose.yml down`
- Rebuild a single service after local Maven build:
  - `mvn -q -f easyshop-product-service/pom.xml -DskipTests package`
  - `docker compose -f easyshop-infra/docker-compose.yml up -d --build product-service`

## Ports
- Config Server: 8888
- Auth Service: 9001
- Product Service: 9002
- Purchase Service: 9003
- API Gateway: 8080
- Frontend: 80

## Notes
- The Dockerfiles expect `target/app.jar` to exist; the deploy script ensures the Maven build step runs before building images.
- Adjust values in `easyshop-infra/.env` to match your environment.

