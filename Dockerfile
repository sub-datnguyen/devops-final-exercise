FROM docker-remote.artifactory.svc.elca.ch/library/tomcat:9.0-jre8-alpine
ENV APPLICATION_JAR="/usr/local/tomcat/webapps/"
RUN chmod -R 777 $APPLICATION_JAR
COPY *.war "$APPLICATION_JAR"