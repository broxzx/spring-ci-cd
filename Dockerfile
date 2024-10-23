FROM eclipse-temurin:17-jre-alpine
LABEL maintainer="fyuizee@gmail.com"

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY target/spring-ci-cd.jar /app/spring-ci-cd.jar

RUN chown -R appuser:appgroup /app
RUN chmod +x /app/spring-ci-cd.jar

USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/spring-ci-cd.jar"]
CMD ["-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-XX:+ExitOnOutOfMemoryError"]