<h1> This project hasn't finished yet!🫠 </h1>

# Jenkins Practice repo


Use docker compose to run the app

```sh
docker compose up --build
```

# Setup GKE cluster

## Install Terraform

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

# Continuous Integration/Continuous Deployment (CI/CD) with Jenkins and Ansible

## Generate SSH keys

```sh
make generate-key 
```

## Run Jenkins server locally (optional)
Then run the following command to get the password:
```sh
docker exec -it jenkins-k8s bash
cat /var/jenkins_home/secrets/initialAdminPassword
```

##  Install Jenkins Plugins
Install the following plugins to integrate Jenkins with Docker, Kubernetes, and GKE:
- Docker
- Docker Pipeline
- Kubernetes
- Google Kubernetes Engine

After installing the plugins, restart Jenkins or run the following command.
```sh
sudo docker restart jenkins-k8s
```

## Configure Jenkins:

### Add webhooks to your GitHub repository to trigger Jenkins builds.

Go to the GitHub repository and click on Settings. Click on Webhooks and then click on Add Webhook. Enter the URL of your Jenkins server (e.g. http://<EXTERNAL_IP>:8081/github-webhook/). Then click on Let me select individual events and select Let me select individual events. Select Push and Pull Request and click on Add Webhook.


### Add Github repository as a Jenkins source code repository.

Go to Jenkins dashboard and click on New Item. Enter a name for your project and select Multibranch Pipeline. Click on OK. Click on Configure and then click on Add Source. Select GitHub and click on Add. Enter the URL of your GitHub repository. In the Credentials field, select Add and select Username with password. Enter your GitHub username and password (or use a personal access token). Click on Test Connection and then click on Save.

### Setup docker hub credentials.

Create a new repository in Docker Hub

From Jenkins dashboard, go to Manage Jenkins > Credentials. Click on Add Credentials. Select Username with password and click on Add. Enter your Docker Hub username, access token, and set ID to dockerhub.


### Setup Kubernetes credentials.

First, create a Service Account for the Jenkins server to access the GKE cluster. Go to the GCP console and navigate to IAM & Admin > Service Accounts. Create a new service account with the Kubernetes Engine Admin role. Give the service account a name and description. Click on the service account and then click on the Keys tab. Click on Add Key and select JSON as the key type. Click on Create and download the JSON file.

Then, from Jenkins dashboard, go to Manage Jenkins > Cloud. Click on New cloud. Select Kubernetes. Enter the name of your cluster, enter the URL and Certificate from your GKE cluster. In the Kubernetes Namespace, enter the namespace of your cluster. In the Credentials field, select Add and select Google Service Account from private`. Enter your project-id and the path to the JSON file.
