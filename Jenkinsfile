pipeline {
  agent any

  options {
    buildDiscarder(logRotator(numToKeepStr: '5', daysToKeepStr: '5'))
    timestamps()
  }

  environment {
    DOCKER_IMAGE = 'magnusdtd/jenkins-practice-app'
    DOCKER_FULL_IMAGE = "${DOCKER_IMAGE}:lastest"
    DOCKER_REGISTRY_CREDENTIAL = 'dockerhub'

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
          sh 'docker compose build'
          sh 'docker images'
        }
      }
    }

    stage('Push Docker Image') {
      steps {
        script {
            echo 'Pushing Docker image to the registry...'
            sh 'docker tag jenkins-practice-app:latest ${DOCKER_IMAGE}:latest'
            docker.withRegistry('', DOCKER_REGISTRY_CREDENTIAL) {
              docker.image("${DOCKER_FULL_IMAGE}").push()
            }
          }
        }
    }

    stage('Deploy to Google Kubernetes Engine') {
      steps {
        script {
            sh("kubectl apply -f ./k8s/namespace.yaml")
            sh("kubectl apply -f ./k8s --recursive")
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
