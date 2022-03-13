###### maven-web-app 
==========================================================
EXECUTE ON BOTH THE JENKINS & LINUX SERVER
===========================================================
Use in user_data when launching ec2-servers.
It updates servers > Install docker > Add ec2-user to docker group > Enable & Starts docker.
--------------------------------------------------------------------------------------------
sudo yum update -y
sudo yum install docker -y
sudo usermod -aG docker ec2-user
sudo chmod 666 /var/run/docker.sock
sudo systemctl enable docker 
sudo systemctl start docker
# sudo systemctl status docker

===========================================================
EXECUTE ON JENKINS EC2 SERVER ONLY
===========================================================
#Installing Jenkins: RUNNING JENKINS AS DOCKER CONTAINER
docker run -u 0 --privileged --name jenkins -p 8080:8080 -p 50000:50000 -it -d -v /home/jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):/usr/bin/docker jenkins/jenkins:latest

docker ps 
docker logs -f <container_ID> #run this to get admin login to jenkins server.
docker exec -it <container_ID> /bin/bash #Enter into jenkins server container and generate key pairs.

ssh-keygen -t rsa

cat ~/.ssh/id_rsa.pub #copy and paste on linux-server ~/.ssh/authorized_keys file.

============================================================
CREATE DEPLOYMENT FILE (deploy.sh) AND PUSH TO GIT REPO.
================================================================
deploy.sh
---------
DOCKER_IMAGE=<docker-hub-username>/<app-name>:<tag>
docker pull $DOCKER_IMAGE
docker run -d -p 8080:8080 $DOCKER_IMAGE
----------------------------------------------------------------

EXECUTE COMMANDS ON JENKINS 
==========================================================
ON JENKINS
-----------
Install maven

===========================
EXECUTE COMMANDS ON JENKINS 
============================
Under Build Environment in Jenkins >> Use secret text(s) or file(s) >> use USER & PASS as variables
----------------------------------------------------------------------------------------------------

DOCKER_IMAGE=<docker-hub-username>/<app-name>:<tag>

# Buil docker image from Dockerfile
docker build -t $DOCKER_IMAGE .

# Login to Docker Hub Repo.
echo $PASS | docker login -u $USER --password-stdin

# Push image to Docker Hub Repo.
docker push $DOCKER_IMAGE

# Connecting to linux-server.
ssh -o StrictHostKeyChecking=no ec2-user@${server_ip}

# Copying deploy.sh file to linuxx-server
scp deploy.sh ec2-user@${server_ip}:~/

# Changing deploy.sh file permission.
ssh ec2-user@${server_ip} "chmod +x deploy.sh"

# Executing the deploy.sh file
ssh ec2-user@${server_ip} ./deploy.ssh
===========================================================


FROM tomcat:9.0-jre8-openjdk-bullseye
RUN cp -r /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps
COPY target/maven-web-app.war /usr/local/tomcat/webapps


