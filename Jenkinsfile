pipeline {
  agent any

  options {
    buildDiscarder(logRotator(numToKeepStr: '5', daysToKeepStr: '5'))
    timestamps()
  }

  environment {
    DOCKER_IMAGE = 'magnusdtd/jenkins-k8s'
    DOCKER_REGISTRY_CREDENTIAL = 'dockerhub'
    DOCKER_FULL_IMAGE = "${DOCKER_IMAGE}:latest"
  }

  stages {

    stage('Run Tests') {
      steps {
        script {
          echo 'Running tests...'
          // I will add tests later
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          dir('app') {
          sh 'docker build -t $DOCKER_FULL_IMAGE .'
          }
        }
      }
    }

    stage('Push Docker Image') {
      steps {
        script {
          echo 'Pushing Docker image to the registry...'
          docker.withRegistry('', DOCKER_REGISTRY_CREDENTIAL) {
            docker.image("${DOCKER_FULL_IMAGE}").push()
          }
        }
      }
    }
  }

  post {
    success {
      script {
        echo 'Build successful.'
      }
    }
    failure {
      script {
        echo 'Build failed!'
      }
    }
    cleanup {
      script {
        echo 'Cleaning up...'
        sh 'docker image prune -f'
      }
    }
  }
}
