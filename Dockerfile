# Dockerfile for Ballerina Banking Services
FROM openjdk:21-slim

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the JAR file
COPY target/bin/dbandlogging2.jar /app/dbandlogging2.jar

# Copy configuration files
COPY Config.docker.toml /app/Config.toml
COPY data/ /app/data/

# Create log directory
RUN mkdir -p /var/log/ballerina

# Create a non-root user
RUN groupadd -r ballerina && useradd -r -g ballerina ballerina
RUN chown -R ballerina:ballerina /app
RUN chown -R ballerina:ballerina /var/log/ballerina
USER ballerina

# Expose ports for all services
EXPOSE 8080 8081 8082

# Run the application
CMD ["java", "-jar", "dbandlogging2.jar"]