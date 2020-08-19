#!/bin/bash

sudo yum update -y
sudo yum upgrade -y
sudo amazon-linux-extras install nginx1.12 -y

echo "<html><title>Test Page</title><body><h1>This server was provisioned by terraform</h1></body></html>" > /usr/share/nginx/html/index.html

sudo systemctl start nginx
