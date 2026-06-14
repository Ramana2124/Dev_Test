FROM eclipse-temurin:8-jre
ADD target/*.jar sample_app.jar
ENTRYPOINT ["java", "-jar", "sample_app.jar"]
