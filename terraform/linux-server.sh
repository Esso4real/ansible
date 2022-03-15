#!/bin/bash

sudo yum update -y \
&& sudo yum install docker -y \
&& sudo usermod -aG docker ec2-user \
&& sudo systemctl enable docker \
&& sudo systemctl start docker

sudo chmod 666 /var/run/docker.sock