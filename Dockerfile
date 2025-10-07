# ---- Build ----
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -q -e -DskipTests dependency:go-offline
COPY src ./src
RUN mvn -q -DskipTests package

# ---- Run ----
FROM eclipse-temurin:17-jre
ENV TZ=Asia/Bangkok
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080

# Expect these envs from Render (via render.yaml):
# POSTGRES_HOST, POSTGRES_PORT, POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD
CMD ["sh","-c","java -Dspring.datasource.url=jdbc:postgresql://${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB} -Dspring.datasource.username=${POSTGRES_USER} -Dspring.datasource.password=${POSTGRES_PASSWORD} -jar app.jar"]
