#!/usr/bin/env groovy
pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "us-east-2"
    }
    stages {
//        stage("Create an EKS Cluster") {
//            steps {
//                script {
//                    dir('terraform') {
//                        sh "pwd"
//                        sh "terraform init"
//                        sh "terraform plan -out=plan.out" 
//                        sh "terraform apply -auto-approve"
//                    }
//                }
//            }
//        }
        stage("Download repo InvokeAI") {
            steps {
                script {
                    sh "git clone https://github.com/invoke-ai/InvokeAI"
                }
            }
        }
        stage("Build app") {
            steps {
                script {
                    dir('InvokeAI') {
                    sh "sudo DOCKER_BUILDKIT=1 docker build -f docker/Dockerfile -t rangelmoddtech/iai:latest ."
                   }
                }
            }
        }
        stage('Push to Docker Hub'){
            steps{
                withCredentials([string(credentialsId: 'DockerPss', variable: 'dockerHubPassword')]) {
        	    sh "echo '${env.dockerHubPassword}' | sudo docker login -u rangelmoddtech --password-stdin"
                    sh 'sudo docker push rangelmoddtech/iai:latest'
                }
            }
        }
        stage("Deploy to EKS") {
            steps {
                withCredentials([string(credentialsId: 'DockerPss', variable: 'dockerHubPassword')]) {
                    dir('kubernetes') {
                        sh "aws eks update-kubeconfig --name poc2-eks-cluster"
                        sh "kubectl create secret docker-registry regcred --docker-server=docker.io/rangelmoddtech/iai --docker-username=rangelmoddtech --docker-password=${env.dockerHubPassword}"
                        sh "kubectl apply -f deployment.yaml"
//                        sh "kubectl apply -f nginx-deployment.yaml"
//                        sh "kubectl apply -f nginx-service.yaml"
                    }
                }
            }
        }
        stage("Destroy") {
            steps {
                script {
                    dir('terraform') {
                        input "Remove infra?"
                        sh "terraform destroy -auto-approve"
                   }
                }
            }
        }
    }
}
