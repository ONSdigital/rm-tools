FROM openjdk:8-jre

COPY target/cfdatabasetool*.jar /opt/cfdatabasetool.jar

EXPOSE 9000

ENTRYPOINT [ "java", "-jar", "/opt/cfdatabasetool.jar" ]