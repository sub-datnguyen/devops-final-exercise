FROM docker-remote.artifactory.svc.elca.ch/library/tomcat:9.0-jre8-alpine
ENV TOMCAT_PATH="/usr/local/tomcat/webapps"
RUN chmod -R 777 "$TOMCAT_PATH"
COPY *.war "$TOMCAT_PATH"