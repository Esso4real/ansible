pipeline {
    agent any

    tools {
        maven 'maven'
    }

    environment {

        IMAGE_NAME = 'esso4real/java-maven-app:v1'
        ANSIBLE_SERVER = "34.230.61.47"
    }

    stages {  
        stage('Build') {
            steps {

                sh "mvn -Dmaven.test.failure.ignore=true clean package"
            }
        }    
        stage('Build docker image') {
            steps {
                script {
                    echo 'building the image from Dockerfile.. .. .. .'
                    echo "connecting to dockerhub repository, and pushing the ${IMAGE_NAME} image .. .. ." 

                    withCredentials([usernamePassword(credentialsId: 'dockerhub-id', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
    
                    sh "docker build -t ${IMAGE_NAME} ." 
                    sh "echo $PASS | docker login -u $USER --password-stdin"
                    sh "docker push ${IMAGE_NAME}"
                    }
                }
            }
        }  
        stage("copy files to ansible server") {
           steps {
               script{
                   echo "copying files to ansible control node"
                   sshagent(['ec2-server-key']) {
                      sh "scp -o StrictHostKeyChecking=no ansible/* ubuntu@${ANSIBLE_SERVER}:/home/ubuntu"
                       
                      withCredentials([sshUserPrivateKey(credentialsId: 'ec2-server-key', keyFileVariable: 'keyfile', usernameVariable: 'user')]){
                       sh 'scp $keyfile ubuntu@$ANSIBLE_SERVER:/home/ubuntu/ssh-key.pem'
                         } 
                       }
                    }
                }
            }

        stage("Execute ansible playbook on target server"){
            steps{
                script {
                    echo "Calling playbook to configure target environment"
                    //need to install another plugin which will ebables us to exec cmdline cmds on remote servers
                    //install ssh pipeline steps plugin
                         def remote = [:]
                         remote.name = "ansible-server"
                         remote.host = "${ANSIBLE_SERVER}"
                         remote.allowAnyHosts = true

                         withCredentials([sshUserPrivateKey(credentialsId: 'ec2-server-key', keyFileVariable: 'keyfile', usernameVariable: 'user')]){
                         remote.user = user
                         remote.identityFile = keyfile
                         sshCommand remote: remote, command: "ansible-playbook playbook.yaml"  
                        } 
                    }         
                }
            }                
        }          
    }
