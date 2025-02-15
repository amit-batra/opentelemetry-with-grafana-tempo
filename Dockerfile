# Use a multi-stage build to create a minimalistic runtime container
# Stage 1: Build the application
FROM maven:3.8.4-openjdk-11 AS build
WORKDIR /dependencies/opentelemetry
RUN curl -L https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar -o opentelemetry-javaagent.jar
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Create the runtime image
FROM openjdk:11-jre
WORKDIR /app
COPY --from=build /app/target/hello-world-with-telemetry-app-0.0.1-SNAPSHOT.jar hello-world-service.jar
COPY --from=build /dependencies/opentelemetry/opentelemetry-javaagent.jar opentelemetry-javaagent.jar
EXPOSE 8080
ENTRYPOINT ["java", "-javaagent:opentelemetry-javaagent.jar", "-jar", "hello-world-service.jar"] 