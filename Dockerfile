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