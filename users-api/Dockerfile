# ===== BUILDER =====
FROM maven:3.8.6-openjdk-8-slim AS builder

WORKDIR /app

COPY pom.xml ./
RUN mvn -e -B dependency:go-offline

COPY src ./src

RUN mvn -e -B clean package -DskipTests

# ===== RUNTIME =====
FROM eclipse-temurin:8-jre

WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8083

CMD ["java", "-jar", "app.jar"]

