#!/bin/ash
#
# Environment variables:
# MAVEN_MIRROR          The url of a local repository to use instead of maven central
# MAVEN_PRIVATE_MIRROR  Optional when MAVEN_MIRROR is in use, a secondary mirror
#
# JNLP Slave:
# ===========
# JENKINS_URL           Url to the Jenkins server
# JENKINS_SECRET        Secret key
#
# SSH Slave:
# ==========
# JENKINS_PASSWORD      Optional, the password for the Jenkins user
#

. /config-jenkins.sh
. /config-ssh.sh

# Define NO_SSH=true to disable sshd
if [ -z "$NO_SSH" ]
then
    exec /usr/sbin/sshd -D -f /etc/ssh/sshd_config
fi
