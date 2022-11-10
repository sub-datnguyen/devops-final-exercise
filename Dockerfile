FROM docker-remote.artifactory.svc.elca.ch/library/tomcat:9.0-jre8-alpine
ENV TZ Europe/Zurich
RUN mkdir -p /usr/local/tomcat/conf/Catalina/localhost
RUN chmod -R a+rwx /usr/local/tomcat/conf/Catalina
RUN chmod -R a+rwx /usr/local/tomcat/webapps
COPY petclinic.war /usr/local/tomcat/webapps/petclinicapp.war
EXPOSE 8080