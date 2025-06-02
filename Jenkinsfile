pipeline {
  agent any

  options {
    buildDiscarder(logRotator(numToKeepStr: '5', daysToKeepStr: '5'))
    timestamps()
  }

  environment {
    DOCKER_IMAGE = 'magnusdtd/jenkins-k8s'
    DOCKER_TAG = "${env.BUILD_NUMBER}".replaceAll('[^a-zA-Z0-9_.-]', '_')
    DOCKER_FULL_IMAGE = "${DOCKER_IMAGE}:${DOCKER_TAG}"
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

    stage('Deploy to Google Kubernetes Engine') {
      agent {
        kubernetes {
          yaml '''
              apiVersion: v1
              kind: Pod
              spec:
                containers:
                - name: helm
                  image: maggnusdtd/jenkins-k8s:lts-jdk17
                  imagePullPolicy: Always
                  command:
                  - cat
                  tty: true
          '''
        }
      }
      steps {
        script {
            container('helm') {
                sh("kubectl apply -f ./k8s/namespace.yaml")
                sh("kubectl apply -f ./k8s --recursive")
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
