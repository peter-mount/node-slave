# ======================================================================
# Dockerfile to add java & ssh to node to allow us to run node as a
# jenkins slave.
# ======================================================================

# jenkins-slave image to pull java from.
FROM area51/jenkins-slave:latest as slave

# The node slave image
FROM area51/node
MAINTAINER Peter Mount <peter@retep.org>

ENV JENKINS_HOME /home/jenkins

ENV GLIBC_VERSION 2.23-r1

ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 172
ENV JAVA_VERSION_BUILD 11
ENV JAVA_PACKAGE       server-jre
ENV URL_ELEMENT        a58eab1ec242421181065cdc37240b08

ENV PATH $PATH:/opt/jdk/bin

# Install glibc (for java) openssh and repositories like git
RUN apk add --update curl &&\
    curl -o glibc.apk \
    	 -L "https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" && \
    apk add --allow-untrusted glibc.apk && \
    curl -o glibc-bin.apk \
    	 -L "https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" && \
    apk add --allow-untrusted glibc-bin.apk && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc/usr/lib && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    rm -f glibc.apk glibc-bin.apk && \
    apk add --update \
    	ca-certificates \
    	openssh \
      git \
      mercurial \
      subversion &&\
    rm -rf /var/cache/apk/*

# Install our scripts
COPY scripts/*.sh /

# Copy ssh config and java from jenkins-slave
COPY --from=slave /etc/ssh.cache/ /etc/ssh.cache/
COPY --from=slave /opt/ /opt/

# Install jenkins user
RUN chmod 500 /docker-entrypoint.sh &&\
    chmod -f 600 /etc/ssh.cache/ssh_host_* &&\
    mkdir -p ~root/.ssh &&\
    chmod 700 ~root/.ssh/ &&\
    echo -e "Port 22\n" >> /etc/ssh/sshd_config &&\
    cp -a /etc/ssh /etc/ssh.cache && \
    mkdir -p /var/run/sshd &&\
    addgroup -g 1000 jenkins &&\
    adduser -h /home/jenkins \
            -u 1000 \
            -G jenkins \
            -s /bin/ash \
            -D jenkins &&\
    echo "jenkins:jenkins" | chpasswd &&\
    sed -e "s|export PATH=|export PATH=/opt/jdk/bin:|" -i /etc/profile &&\
    mkdir -p ${JENKINS_HOME} &&\
    chown -R jenkins:jenkins ${JENKINS_HOME}

VOLUME ${JENKINS_HOME}
ENTRYPOINT  ["/docker-entrypoint.sh"]

EXPOSE 22/tcp
