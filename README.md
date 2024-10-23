
## Download docker
```bash
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
```

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

```bash
# To install the latest version, run:
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify that the Docker Engine installation is successful by running the `hello-world` image.
sudo docker run hello-world

# Check that docker container was created
sudo docker ps -a
```
## Set up github runner in server
```bash
docker run -d \
  --name github-runner \
  --restart always \
  -e REPO_URL="https://github.com/<your-username>/<your-repo>" \
  -e RUNNER_NAME="runner-name" \
  -e RUNNER_TOKEN="<your-runner-token>" \
  -e RUNNER_WORKDIR="/tmp/github-runner" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  myoung34/github-runner:latest
```

## Create docker-compose and Dockerfile if needed
`Dockerfile`
```Dockerfile
FROM amazoncorretto:17.0.7-alpine

ARG APPLICATION_USER=appuser
RUN adduser --no-create-home -u 1000 -D $APPLICATION_USER

RUN mkdir /app && \
    chown -R $APPLICATION_USER /app

USER 1000

COPY --chown=1000:1000 ./target/spring-ci-cd.jar /app/spring-ci-cd.jar
WORKDIR /app

EXPOSE 8080
ENTRYPOINT [ "java", "-jar", "/app/spring-ci-cd.jar" ]
```

`docker-compose.yml`
```yml
version: '3.8'

services:
  spring-ci-cd:
    container_name: spring-ci-cd
    build:
      context: ./
    ports:
      - "8080:8080"
    networks:
      - backend

networks:
  backend:
    driver: bridge
```

## Create ci-cd.yml
Create ci-cd.yml inside the following directory: .github/workflows/

Example of ci-cd.yml
```yml
name: Spring Boot CI/CD github

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build:
    runs-on: self-hosted
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Build with Maven
        run: ./mvnw clean install -DskipTests

      - name: Run tests
        run: ./mvnw test

      - name: Archive results
        uses: actions/upload-artifact@v3
        with:
          name: jar-file
          path: target/*.jar

  deploy:
    runs-on: self-hosted
    needs: build
    steps:
      - name: Stop existing containers
        run: |
          docker-compose down

      - name: Build and run Docker Compose
        run: |
          docker-compose pull
          docker-compose up -d --build
```

