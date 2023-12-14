# Base image with Maven installed already
FROM maven:3.9-eclipse-temurin-21 AS builder

# Copy the entire project into the Docker image
COPY . .

# Build project
RUN mvn clean package

FROM debian:11-slim AS download
RUN apt-get update && apt-get install -y udev 

# Base image containing OpenJDK 17
From gcr.io/distroless/java17-debian11
ENV LIB_DIR_PREFIX x86_64
COPY --from=download /usr/lib/${LIB_DIR_PREFIX}-linux-gnu/libudev.so.1 /usr/lib/${LIB_DIR_PREFIX}-linux-gnu/libudev.so.1
COPY --from=builder target/*.jar /ward.jar
COPY --from=builder pom.xml /pom.xml
EXPOSE 4000
ENTRYPOINT ["java", "-jar", "/ward.jar"]

