FROM openjdk:8-jre

COPY target/cfdatabasetool*.jar /opt/cfdatabasetool.jar

EXPOSE 9000

ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -jar /opt/cfdatabasetool.jar" ]
