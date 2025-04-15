#!/usr/bin/env groovy

library identifier: 'jsl-ex-ch8@master', retriever:modernSCM(
[$class: 'GitSCMSource' ,
remote: 'https://github.com/marcualexandru21/jsl-ex-ch8.git' ,
credentialsId: 'github-acc-token-twn'
])

env.IMAGE_NAME = "mbradu/ex-ch9-twn:nodejs-app-"
env.CREDENTIALS_ID_DOCKER_HUB = "dockerhub-credentials-token"
env.CREDENTIALS_ID_GITHUB = "github-acc-token-twn"
env.NAME = "bradu"
env.EMAIL = "marcualexandru21@gmail.com"
env.REMOTE_URL = "github.com/marcualexandru21/Ch9-aws-exercise.git"
env.PUSH_BRANCH_NAME = "master"

pipeline {
    agent any
    tools {
        nodejs 'node-23.9'
    }

    stages {

        stage("npm install") {
            steps {
                script {
                    sh '''
                         cd ./app/
                        npm install
                    '''
                }
            }
        }

        stage("get version and increment version") {
            steps {
                script {
                   def version = sh(script: 'cd ./app/ && npm pkg get version', returnStdout: true).trim()
                   def bar = "-"
                   IMAGE_NAME = "${IMAGE_NAME}${version}${bar}${BUILD_NUMBER}"
                   sh '''
                       cd ./app/
                       npm version patch
                   '''
                }
            }
        }

        stage("Build docker image") {
            steps {
                script {
                   buildDockerImage "${IMAGE_NAME}"
                }
            }
        }

        stage("Docker hub login") {
            steps {
                script {
                   dockerHubLogin "${CREDENTIALS_ID_DOCKER_HUB}"
                }
            }
        }

        stage("Push to docker hub") {
            steps {
                script {
                   dockerPushImage "${IMAGE_NAME}"
                }
            }
        }

        stage("deploy") {
            steps {
                script {
                    def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME}"
                    def userAndServer = "ec2-user@3.69.99.155"
                    sshagent(['ec2-server-key-2']) {
                        sh "scp -o StrictHostKeyChecking=no server-cmds.sh ${userAndServer}:/home/ec2-user"
                        sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ${userAndServer}:/home/ec2-user"
                        sh "ssh -o StrictHostKeyChecking=no ${userAndServer} ${shellCmd}"
                    }
                }
            }
        }

        stage("Push to Remote URL") {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${CREDENTIALS_ID_GITHUB}", passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh 'git config user.email "${EMAIL}"'
                        sh 'git config user.name "${NAME}"'

                        sh 'git status'
                        sh 'git branch'
                        sh 'git config --list'

                        sh "git remote set-url origin https://${USER}:${PASS}@${REMOTE_URL}"
                        sh 'git add .'
                        sh 'git commit -m "ci: version bump"'
                        sh "git push origin HEAD:${PUSH_BRANCH_NAME}"
                    }
                }
            }
        }


    }

}
