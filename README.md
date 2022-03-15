DEPLOYING PYTHON APPLICATION ON AWS.

Create installation script, name it installation.sh.
Run the script on Sever (host machine) to install docker, curl, openssh-server, Jenkins container, terraform and aws cli

#bash ./installation.sh

 installation.sh
=========================================================================================
#!/bin/bash

sudo apt-get update -y \
&& sudo apt-get install docker.io -y \
&& sudo usermod -aG docker ec2-user \
&& sudo systemctl enable docker \
&& sudo systemctl start docker

sudo apt install curl -y
sudo apt install openssh-server -y

sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update -y && sudo apt-get install terraform -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

sudo chmod 666 /var/run/docker.sock

docker run --privileged -u 0 --name jenkins -it -d -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):/usr/bin/docker jenkins/jenkins:lts

=========================================================================================

Add access and secret key to server - aws configure
# aws configure

Exec into jenkins container and run script on Jenkins container to install curl, terraform and aws cli.
Do a docker ps to get container ID then docker exec.

# docker ps
# docker exec -it <container_ID> /bin/sh

Run the second installation script in Jenkins container with below configuration.

# bash installation.sh

=========================================================================================
#!/bin/bash

apt-get update -y 
apt install curl -y

apt-get update && apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update -y && apt-get install terraform -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

=========================================================================================

Add access and secret key to jenkins container  
#aws configure

=========================================================================================
IN JENKINS GUI.

Install the SSH-AGENT plugin / Credential-binding
Add EC2 instance (SSH with username + private key), copy contents of .pem file to Jenkins.
and  DockerHub login credentials

To add credentials, go to;
Jenkins sever - GUI; under Manage Jenkins select Manage Credentials, Add new credentials.
DockerHub: Select username and password
EC2 Instance: Select use SSH username with private key.