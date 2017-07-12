#!/bin/ash

# /opt/jenkins is available for the workspace work files
if [ ! -d /opt/jenkins ]
then
    mkdir -p /opt/jenkins
    chown jenkins:jenkins /opt/jenkins
fi

# Bug JENKINS-32542 I found I hit this bug suddenly then found JENKINS-29674 mentioned
# about the loopback used by maven and the slave. Adding this seems (as I write this)
# to fix this bug.
#
# Now we have to do this at container startup as the host file is replaced by docker
# everytime the container is started.
echo "127.0.0.1 dockerhost" >>/etc/hosts
