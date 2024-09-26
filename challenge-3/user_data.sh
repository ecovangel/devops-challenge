#!/bin/bash
# Install Apache HTTP server
yum install -y httpd
# Start the Apache service
systemctl start httpd
# Enable the Apache service to start on boot
systemctl enable httpd
# Create a test HTML file
echo "It works!" > /var/www/html/index.html
