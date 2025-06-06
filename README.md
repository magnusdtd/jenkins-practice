# **Deploying a rembg model to GKE using Jenkins, Terraform, Ansible, Helm Chart** 
- [**Sections**](#deploying-a-rembg-model-to-gke-using-jenkins-terraform-ansible-helm-chart)
  - [I. Introduction](#i-introduction)
  - [II. Run the app locally with Docker compose](#ii-run-the-app-locally-with-docker-compose)
  - [III. Setup GKE cluster](#iii-setup-gke-cluster)
      - [1. Install Terraform](#1-install-terraform)
      - [2. Generate SSH keys](#2-generate-ssh-keys)
      - [3. Use Terraform to setup cluster](#3-use-terraform-to-setup-cluster)
      - [4. Create deployments in GKE cluster](#4-create-deployments-in-gke-cluster)
  - [IV. Continuous Integration/Continuous Deployment (CI/CD) with Jenkins and Ansible](#iv-continuous-integrationcontinuous-deployment-cicd-with-jenkins-and-ansible)
      - [1. Create Jenkins server with Ansible playbook](#1-create-jenkins-server-with-ansible-playbook)
      - [2. Jenkins Installation](#2-jenkins-installation)
      - [3. Install Jenkins Plugins](#3-install-jenkins-plugins)
      - [4. Configure Jenkins](#4-configure-jenkins)
      - [5. Trigger to run Jenkins pipeline](#5-trigger-to-run-jenkins-pipeline)
  - [V. Resources](#v-resources)

## I. Introduction
This document provides a comprehensive guide on deploying a **rembg** model to **Google Kubernetes Engine (GKE)** using **Jenkins, Terraform, Ansible**, and **Helm Chart**. The **rembg** model is a powerful tool for removing backgrounds from images, and deploying it on **GKE** allows for scalable and efficient image processing. This guide will take you through the necessary steps to set up the infrastructure, deploy the model, and configure continuous integration and deployment (CI/CD) pipelines for automated deployments.

## II. Run the app locally with Docker compose
The app use a [rembg model](https://github.com/danielgatis/rembg) to remove the back ground of the input image. Use docker compose to run the app

```sh
docker compose up --build
```

## III. Setup GKE cluster

### 1. Install Terraform

Using the following commands to install terrofrm
```sh
# Install repository addition dependencies
sudo apt update && sudo apt install  software-properties-common gnupg2 curl
# Import repository GPG key
curl https://apt.releases.hashicorp.com/gpg | gpg --dearmor > hashicorp.gpg
sudo install -o root -g root -m 644 hashicorp.gpg /etc/apt/trusted.gpg.d/
# Add Hashicorp repository to Ubuntu system
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
# Install terraform
sudo apt install terraform
```
Check the version of terraform installed on your system
```sh
terraform --version
```

### 2. Generate SSH keys
First make a folder names "secret" at path "iac/secrets". Then play your service acount credentials file. Update the `iac/terraform/variables.tf` and `iac/ansible/create_compute_instance.yaml` file with your credentials file name. After that, run the following commands:
```sh
make genkey 
```

### 3. Use Terraform to setup cluster
```sh
cd iac
make tf-init
make tf-plan
make tf-apply
```

### 4. Create deployments in GKE cluster
Create namespace
```sh
kubectl create ns nginx-ingress
kubectl create ns model-serving
```

Deploy NGINX-ingress
```sh
kubens nginx-ingress
helm upgrade --install my-app ./k8s/nginx-ingress
```

Get External IP of NGINX-ingress
```sh
kubens nginx-ingress
kubectl get svc
```

Deploy the app
```sh
kubens model-serving
helm upgrade --install my-app ./k8s/my-app
```


## IV. Continuous Integration/Continuous Deployment (CI/CD) with Jenkins and Ansible

### 1. Create Jenkins server with Ansible playbook
```sh
make ansible-deploy
```

### 2. Jenkins Installation
Connect to GCE:
```sh
ssh -i secrets/jenkins_key <your username>@<GCE_EXTERNAL_IP>
# The GCE_EXTERNAL_IP is in your iac/ansible/inventory/inventory.ini file
```

Access Jenkins UI:

Retrieve password by run the following command: 
```sh
sudo docker exec jenkins-k8s cat /var/jenkins_home/secrets/initialAdminPassword
```
Navigate to http://[GCE_EXTERNAL_IP]:8080 and login.

### 3. Install Jenkins Plugins
Install the following plugins to integrate Jenkins with Docker, Kubernetes, and GKE:
- Docker
- Docker Pipeline
- Kubernetes
- Google Kubernetes Engine

After installing the plugins, restart Jenkins or run the following command.
```sh
sudo docker restart jenkins-k8s
``` 

### 4. Configure Jenkins:

**Add webhooks to your GitHub repository to trigger Jenkins builds.**

Go to the GitHub repository and click on Settings. Click on Webhooks and then click on Add Webhook. Enter the URL of your Jenkins server (e.g. http://<EXTERNAL_IP>:8080/github-webhook/). Then click on Let me select individual events and select Let me select individual events. Select Push and Pull Request and click on Add Webhook.


***Add Github repository as a Jenkins source code repository.***

Go to Jenkins dashboard and click on New Item. Enter a name for your project and select Multibranch Pipeline. Click on OK. In the Branch Sources section, click on Add Source then select GitHub. Enter the URL of your GitHub repository. In the Credentials field, select Add and select Username with password. Enter your GitHub username and password (or use a personal access token). Click on Test Connection and then click on Save.

***Setup docker hub credentials.***

Create a new repository in Docker Hub.

From Jenkins dashboard, go to Manage Jenkins > Credentials. Click on Add Credentials. Select Username with password and click on Add. Enter your Docker Hub username, access token, and set ID to dockerhub.


***Setup Kubernetes credentials.***

First, create a Service Account for the Jenkins server to access the GKE cluster. Go to the GCP console and navigate to IAM & Admin > Service Accounts. Create a new service account with the Kubernetes Engine Admin role. Give the service account a name and description. Click on the service account and then click on the Keys tab. Click on Add Key and select JSON as the key type. Click on Create and download the JSON file.

Then, from Jenkins dashboard, go to Manage Jenkins > Cloud. Click on New cloud. Select Kubernetes. Enter the name of your cluster, enter the URL and Certificate from your GKE cluster (in the Control Plane Networking section, Public endpoint). In the Kubernetes Namespace, enter the namespace of your cluster(e.g. model-serving). In the Credentials field, select Add and select Google Service Account from private`. Enter your project-id and the path to the JSON file.

When you add the Certificate, you need to remove the space before the text. If you copy the text directly, an issue may occured. Use the following command to save the cluster certifate: 
```sh
openssl s_client -connect <CLUSTER_ENDPOINT>:443 -showcerts </dev/null 2>/dev/null | openssl x509 -outform PEM > cluster-cert.pem
```
### 5. Trigger to run Jenkins pipeline
After adding credentials, push a commit to the repo to see what happen.

## V. Resources
- [Ansible Docs](https://docs.ansible.com/ansible/latest/index.html)
- [Terraform Docs](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started)
- [ChatOpsLLM: Effortless MLOps for Powerful Language Models](https://github.com/bmd1905/ChatOpsLLM)
- [Face Detection ML System](https://github.com/DucLong06/face-detection-ml-system)