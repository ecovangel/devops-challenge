Here is a simplified and comprehensive version of the `SOLUTION.md` for the Skyward DevOps Challenge, summarizing all three challenges and their aims:

---

# Skyward DevOps Challenge - Solution

## Overview
This repository showcases the solutions for the Skyward DevOps Challenge, aimed at evaluating proficiency in Docker, Kubernetes, Terraform, and CI/CD methodologies. Below is a comprehensive summary of the three challenges and the approaches taken to address them.


---

## Challenge 1: Docker and CI/CD

### Aim
The goal of Challenge 1 is to create a simple Python web server, containerize it using Docker, and automate its build and push to Docker Hub using GitHub Actions.

### Steps
1. **Build a Python Web Server**:  
   Developed a basic Python web server that listens on port `8000` and serves a simple HTML page. The Python `http.server` library was used to create this server.
   
2. **Dockerize the Web Server**:  
   A `Dockerfile` was written to create a Docker image for the web server. The image was built using the official `python:3.9-slim` image. The `EXPOSE` instruction was used to make port 8000 available.

3. **Push Docker Image to Docker Hub**:  
   A GitHub Actions workflow was configured to build the Docker image automatically, tag it, and push it to Docker Hub using the `docker/build-push-action`.

**Optional Features Implemented**:  
- The Docker container accepts arguments for `host` and `port`.
- The image was passed through the `dive` tool to check for vulnerabilities and optimizations.

---

## Challenge 2: Kubernetes and Helm

### Aim
Challenge 2 involves deploying the web server created in Challenge 1 to a Kubernetes cluster using Helm. The goal is to develop a Helm chart for managing the deployment and exposing the application via an Ingress.

### Steps
1. **Create a Helm Chart**:  
   Developed a Helm chart to define Kubernetes resources for the web server, including deployments, services, and ingress rules. The chart includes a `values.yaml` file for configurable parameters, such as the Docker image version, service type, and ingress settings.

2. **Deploy to Minikube**:  
   Deployed the Helm chart to a local Kubernetes cluster using Minikube. The application was exposed through an Nginx Ingress controller, allowing access to the web server via a domain like `skyward.192.168.58.2.nip.io`.

3. **Test the Deployment**:  
   Verified the deployment by accessing the web server through the ingress. The HTML page served by the Python web server was successfully displayed in the browser.

**Optional Features Implemented**:  
- The Helm chart was validated using `helm lint` to ensure best practices.
- Documentation for the Helm chart was generated using `norwoodj/helm-docs`.
- End-to-end testing of the Helm chart was integrated with GitHub Actions.
- Validated `values.yaml` using `values.schema.json`.


---

## Challenge 3: Infrastructure as Code with Terraform

### Aim
Challenge 3 focuses on using Terraform to define infrastructure as code (IaC) for deploying an AWS infrastructure that hosts a simple web server. The goal is to build infrastructure components like an EC2 instance, load balancer, and S3 buckets.

### Steps
1. **Create Terraform Configuration**:  
   Terraform manifests were written to define AWS resources. This included:
   - VPC
   - EC2 instances with user data to install and run `httpd`
   - ALB (Application Load Balancer)
   - S3 bucket for storage

2. **Deploy Infrastructure**:  
   The infrastructure was deployed to AWS using the Terraform configuration, and the EC2 instance was configured to serve the default Apache HTTP page via the load balancer.

3. **Verify Deployment**:  
   The deployment was validated by accessing the load balancer URL and seeing the default web page served by the EC2 instance running Apache.

**Optional Features Implemented**:  
- Terraform best practices were followed, including state management and modularizing the code.
- Terraform syntax was checked using `tflint` and `tfsec`.

---

## Conclusion
Each challenge in the Skyward DevOps task was completed successfully, demonstrating skills in Docker, Kubernetes, Terraform, and CI/CD automation.