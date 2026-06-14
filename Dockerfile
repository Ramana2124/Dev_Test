FROM openjdk:8
ADD target/*.jar sample_app.jar
ENTRYPOINT ["java", "-jar", "sample_app.jar"]
