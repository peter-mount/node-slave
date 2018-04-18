imageName = 'area51/node-slave'

properties( [
  buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '7', numToKeepStr: '10')),
  disableConcurrentBuilds(),
  disableResume(),
  pipelineTriggers([
    upstream('/peter-mount/node/master'),
    cron('H H * * 1')
  ])
])

node( 'AMD64' ) {
  stage( 'Prepare' ) {
    checkout scm
    sh 'docker pull area51/node:latest'
  }

  stage( 'Build' ) {
    sh 'docker build -t ' + imageName + ' .'
  }

  stage( 'Publish' ) {
    sh 'docker push ' + imageName
  }
}
