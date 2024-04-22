pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'roseaw-dockerhub'
        DOCKER_IMAGE = 'cithit/backstage'
        IMAGE_TAG = "build-${env.BUILD_NUMBER}"
        GITHUB_URL = 'https://github.com/WTaylor8miami/backstage-deploy.git'
        KUBECONFIG = credentials('taylorw8-225')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']],
                          userRemoteConfigs: [[url: "${GITHUB_URL}"]]])
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'yarn install'
            }
        }

        stage('Lint and Test') {
            steps {
                sh 'yarn lint'
                sh 'yarn test'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${IMAGE_TAG}").inside {
                        sh 'yarn build'
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS_ID}") {
                        docker.image("${DOCKER_IMAGE}:${IMAGE_TAG}").push()
                    }
                }
            }
        }

        stage('Deploy to Dev Environment') {
            steps {
                script {
                    sh "kubectl apply -f k8s/deployment-dev.yaml --record"
                }
            }
        }

        stage('Run Backstage Tests') {
            steps {
                script {
                    docker.image("${DOCKER_IMAGE}:${IMAGE_TAG}").inside {
                        sh "yarn test:integration"
                    }
                }
            }
        }

        stage('Deploy to Prod Environment') {
            when {
                branch 'main'
            }
            steps {
                script {
                    sh "kubectl apply -f k8s/deployment-prod.yaml --record"
                }
            }
        }

        stage('Check Kubernetes Cluster') {
            steps {
                script {
                    sh "kubectl get all"
                }
            }
        }
    }

    post {
        always {
            cleanWs()
            // Include notifications here if required, e.g., Slack or email notifications.
        }
    }
}

