#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo yum -y install wget
sudo wget -P /var/www/html/ https://s3.us-west-1.amazonaws.com/nimbusdevops.com/spooky/index.html
sudo wget -P /var/www/html/ https://s3.us-west-1.amazonaws.com/nimbusdevops.com/spooky/style.css
sudo wget -P /var/www/html/ https://s3.us-west-1.amazonaws.com/nimbusdevops.com/spooky/madlib.html
sudo wget -P /var/www/html/ https://s3.us-west-1.amazonaws.com/nimbusdevops.com/spooky/spooky.png
sudo wget -P /var/www/html/ https://s3.us-west-1.amazonaws.com/nimbusdevops.com/spooky/spooky.mp3
sudo systemctl enable httpd
sudo systemctl start httpd