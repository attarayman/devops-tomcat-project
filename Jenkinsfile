pipeline {
    agent any
    
    tools {
        maven 'Maven'
        jdk 'JDK17'
    }
    
    environment {
        DOCKER_IMAGE = 'devops-app'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        TOMCAT_URL = 'http://localhost:8080'
        TOMCAT_CREDENTIALS = credentials('tomcat-credentials')
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from GitHub...'
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                echo 'Building application with Maven...'
                sh 'mvn clean compile'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Running unit tests...'
                sh 'mvn test'
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('Package') {
            steps {
                echo 'Creating WAR package...'
                sh 'mvn package -DskipTests'
            }
            post {
                success {
                    archiveArtifacts artifacts: '**/target/*.war', fingerprint: true
                }
            }
        }
        
        stage('Code Quality Analysis') {
            steps {
                echo 'Running code quality checks...'
                // Add SonarQube or other quality tools here
                sh 'mvn verify -DskipTests'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                    sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                }
            }
        }
        
        stage('Docker Security Scan') {
            steps {
                echo 'Scanning Docker image for vulnerabilities...'
                // Add Trivy or other security scanning tools
                script {
                    sh "docker inspect ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                echo 'Deploying to Tomcat...'
                script {
                    // Option 1: Direct WAR deployment
                    sh """
                        curl -v -u ${TOMCAT_CREDENTIALS_USR}:${TOMCAT_CREDENTIALS_PSW} \
                        -T target/devops-app.war \
                        "${TOMCAT_URL}/manager/text/deploy?path=/devops-app&update=true"
                    """
                }
            }
        }
        
        stage('Deploy Docker Container') {
            steps {
                echo 'Deploying Docker container...'
                script {
                    // Stop and remove existing container
                    sh 'docker-compose down || exit 0'
                    // Start new container
                    sh 'docker-compose up -d'
                }
            }
        }
        
        stage('Health Check') {
            steps {
                echo 'Performing health check...'
                sleep time: 30, unit: 'SECONDS'
                script {
                    sh 'curl -f http://localhost:8080/health || exit 1'
                }
            }
        }
        
        stage('Smoke Tests') {
            steps {
                echo 'Running smoke tests...'
                script {
                    sh 'curl -f http://localhost:8080/hello || exit 1'
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
            // Add notifications (email, Slack, etc.)
        }
        failure {
            echo 'Pipeline failed!'
            // Add failure notifications
        }
        always {
            echo 'Cleaning up...'
        }
    }
}
