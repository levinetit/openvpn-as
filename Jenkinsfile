pipeline {
    agent any

    environment {
        // Imaginea Docker Hub
        IMAGE_NAME = 'levinetit/openvpn-as'
        IMAGE_TAG  = 'latest'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh "docker build --no-cache --pull -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker logout
                    """
                }
            }
        }
    }

    post {
        always {
            // Curăță imaginile locale după push
            sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true"
        }
    }
}
