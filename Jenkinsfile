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
        stage("Build InvokeAI Image") {
            steps {
                script {
                    sh "git clone https://github.com/invoke-ai/InvokeAI"
                    sh "cd InvokeAI"
                    sh "sudo DOCKER_BUILDKIT=1 docker build -f docker/Dockerfile -t rangelmoddtech/iai:latest ."
                }
            }
        }
        stage('Push to DHub'){
            steps{
                withCredentials([usernamePassword(credentialsId: 'DockerPss', passwordVariable: 'dockerHubPassword', usernameVariable: 'rangelmoddtech')]) {
        	    sh "sudo docker login -u ${env.dockerHubUser} -p ${env.dockerHubPassword}"
                    sh 'sudo docker push rangelmoddtech/iai:latest'
                }
            }
        }
        stage("Deploy to EKS") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DockerPss', passwordVariable: 'dockerHubPassword', usernameVariable: 'rangelmoddtech')]) {
                    dir('kubernetes') {
                        sh "aws eks update-kubeconfig --name poc2-eks-cluster"
                        sh "kubectl create secret docker-registry regcred --docker-server=docker.io/rangelmoddtech/iai:latest --docker-username=${env.dockerHubUser} --docker-password=${env.dockerHubPassword}"
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
