FROM docker-remote.artifactory.svc.elca.ch/library/tomcat:9.0-jre8-alpine
ENV TZ Europe/Zurich
RUN chmod -R 777 /usr/local/tomcat/webapps
COPY *.war /usr/local/tomcat/webapps