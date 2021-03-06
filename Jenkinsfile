pipeline {
    agent any

    environment {

        IMAGE_NAME = 'esso4real/python-app:v5'
        ANSIBLE_SERVER = "172.16.26.144"
    }
     
    stages {
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

         stage('Provisioning server') {
            environment {
                AWS_ACCESS_KEY_ID = ""
                AWS_SECRET_KEY_ID = ""
            }
            steps{
                echo 'provisining ec2 instances .. ..  ...'
                script{
                    dir('terraform') {
                    sh "terraform init"
                    sh "terraform apply --auto-approve"
                    //sh "terraform destroy --auto-approve"
                    
                    EC2_LINUX_IP = sh(
                        script: "terraform output ec2_public_ip",
                        returnStdout: true
                    ).trim()
    
                }
            }
        }
    }   



        stage("copy files to ansible server") {
           steps {
               script{
                   echo "copying files to ansible control node"
                   sshagent(['ansible-server-key']) {
                      sh "scp -o StrictHostKeyChecking=no ansible/* eawangya@${ANSIBLE_SERVER}:/home/eawangya"
                       
                      withCredentials([sshUserPrivateKey(credentialsId: 'ec2-server-key', keyFileVariable: 'keyfile', usernameVariable: 'user')]){
                       sh 'scp $keyfile eawangya@$ANSIBLE_SERVER:/home/eawangya/ssh-key.pem'
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

                         withCredentials([sshUserPrivateKey(credentialsId: 'ansible-server-key', keyFileVariable: 'keyfile', usernameVariable: 'user')]){
                         remote.user = 'eawangya'
                         remote.password = 'root'
                         remote.identityFile = 'keyfile' 
                         sshCommand remote: remote, command: "ansible-playbook playbook.yaml"  
                         sshCommand remote: remote, command: "rm -rf ~/ssh-key.pem" 
                        } 
                    }         
                }
            }                
        }          
    
