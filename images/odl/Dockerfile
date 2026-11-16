# OpenDaylight Chromium (karaf 0.24.0) на Java 21.
# Официального поддерживаемого образа на Docker Hub нет (opendaylight/odl устарел), собираем сами.
FROM eclipse-temurin:21-jre
ARG ODL_VER=0.24.0
ADD https://nexus.opendaylight.org/content/repositories/opendaylight.release/org/opendaylight/integration/karaf/${ODL_VER}/karaf-${ODL_VER}.tar.gz /tmp/odl.tar.gz
RUN tar -xzf /tmp/odl.tar.gz -C /opt && mv /opt/karaf-${ODL_VER} /opt/odl && rm /tmp/odl.tar.gz
WORKDIR /opt/odl
EXPOSE 6633 6653 8181 8101
CMD ["/opt/odl/bin/karaf", "server"]
