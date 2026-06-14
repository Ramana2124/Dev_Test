pipeline {
    agent {
        node {
            label 'maven'
        }
    }

    environment {
        PATH = "/usr/share/maven/bin:$PATH"
        AWS_REGION = 'ap-south-1'
        AWS_ACCOUNT_ID = '784369108574'
        ECR_REPO_NAME = 'sample-app'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        ECR_REGISTRY = "784369108574.dkr.ecr.ap-south-1.amazonaws.com"
        IMAGE_NAME = "784369108574.dkr.ecr.ap-south-1.amazonaws.com/sample-app:${env.BUILD_NUMBER}"
        EKS_CLUSTER_NAME = 'YOUR_EKS_CLUSTER_NAME'
    }

    stages {

        stage('Checkout') {
            steps {
                echo '----------- Checkout Started ----------'
                checkout scm
                echo '----------- Checkout Completed ----------'
            }
        }

        stage('Build') {
            steps {
                echo '----------- Build Started ----------'
                sh 'mvn clean package -Dmaven.test.skip=true'
                echo '----------- Build Completed ----------'
            }
        }

        stage('Test') {
            steps {
                echo '----------- Unit Test Started ----------'
                sh 'mvn surefire-report:report'
                echo '----------- Unit Test Completed ----------'
            }
        }

        stage('Docker Build') {
            steps {
                echo '----------- Docker Build Started ----------'
                sh "docker build -t sample-app:${env.BUILD_NUMBER} ."
                sh "docker tag sample-app:${env.BUILD_NUMBER} 784369108574.dkr.ecr.ap-south-1.amazonaws.com/sample-app:${env.BUILD_NUMBER}"
                echo '----------- Docker Build Completed ----------'
            }
        }

        stage('ECR Login & Push') {
            steps {
                echo '----------- ECR Push Started ----------'
                sh """
                    aws ecr get-login-password --region ap-south-1 | \
                    docker login --username AWS --password-stdin \
                    784369108574.dkr.ecr.ap-south-1.amazonaws.com
                """
                sh "docker push 784369108574.dkr.ecr.ap-south-1.amazonaws.com/sample-app:${env.BUILD_NUMBER}"
                echo '----------- ECR Push Completed ----------'
            }
        }

        stage('Deploy to EKS') {
            steps {
                echo '----------- EKS Deploy Started ----------'
                sh """
                    aws eks update-kubeconfig \
                        --region ap-south-1 \
                        --name ${EKS_CLUSTER_NAME}
                """
                sh """
                    sed -i 's|IMAGE_PLACEHOLDER|784369108574.dkr.ecr.ap-south-1.amazonaws.com/sample-app:${env.BUILD_NUMBER}|g' k8s/deployment.yaml
                """
                sh 'kubectl apply -f k8s/deployment.yaml'
                sh 'kubectl apply -f k8s/service.yaml'
                echo '----------- EKS Deploy Completed ----------'
            }
        }

    }

    post {
        success {
            echo 'Pipeline completed successfully! Application deployed to EKS!'
        }
        failure {
            echo 'Pipeline failed! Check logs for details.'
        }
    }
}
