# Variables
SHELL := /bin/bash
SSH_KEY_DIR := secrets
SSH_KEY_PATH := $(SSH_KEY_DIR)/jenkins_key
TERRAFORM_DIR := terraform
ANSIBLE_DIR := ansible
REQUIRED_DIRS := $(SSH_KEY_DIR) $(TERRAFORM_DIR) $(ANSIBLE_DIR)

# Colors for output
GREEN := \033[0;36m # Cyan
RED := \033[0;35m   # Magenta
YELLOW := \033[0;33m
NC := \033[0m

# ---------------------------------------------------------------------------------#
# Utilities                                                                        #
# ---------------------------------------------------------------------------------#
# Default target
.DEFAULT_GOAL := help

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@grep -E '^\.[PHONY]+: [a-zA-Z0-9_-]+.*$$' $(MAKEFILE_LIST) | awk '{print "  make " $$2}'

# Check and create required directories
.PHONY: check-dirs
check-dirs:
	@if [ -z "$(REQUIRED_DIRS)" ]; then \
		echo -e "$(RED)Error: REQUIRED_DIRS is not defined$(NC)"; \
		exit 1; \
	fi
	@echo -e "$(GREEN)Checking required directories...$(NC)"
	@for dir in $(REQUIRED_DIRS); do \
		if [ ! -d $$dir ]; then \
			echo -e "$(YELLOW)Creating directory: $$dir$(NC)"; \
			mkdir -p $$dir || { echo -e "$(RED)Failed to create directory: $$dir$(NC)"; exit 1; }; \
		else \
			echo -e "$(GREEN)Directory exists: $$dir$(NC)"; \
		fi; \
	done
	@echo -e "$(GREEN)Directory check complete$(NC)"
# ---------------------------------------------------------------------------------#

# ---------------------------------------------------------------------------------#
# Create SSH keys in order to make a Jnekins server in GCP
# ---------------------------------------------------------------------------------#
# Check SSH key permissions
.PHONY: check-ssh-perms
check-ssh-perms:
	@if [ -f $(SSH_KEY_PATH) ]; then \
		chmod 600 $(SSH_KEY_PATH) || { echo -e "$(RED)Failed to set permissions for $(SSH_KEY_PATH)$(NC)"; exit 1; }; \
		chmod 644 $(SSH_KEY_PATH).pub || { echo -e "$(RED)Failed to set permissions for $(SSH_KEY_PATH).pub$(NC)"; exit 1; }; \
		echo -e "$(GREEN)SSH key permissions set correctly$(NC)"; \
	else \
		echo -e "$(RED)SSH key not found at $(SSH_KEY_PATH)$(NC)"; \
		exit 1; \
	fi

# Generate SSH keys
.PHONY: genkey
genkey: check-dirs
	@echo -e "$(GREEN)Generating SSH key pair...$(NC)"
	@if [ ! -f $(SSH_KEY_PATH) ]; then \
		ssh-keygen -t rsa -b 2048 -f $(SSH_KEY_PATH) -C "longhd" -N "" || { echo -e "$(RED)Failed to generate SSH key pair$(NC)"; exit 1; }; \
		echo -e "$(GREEN)SSH key pair generated successfully$(NC)"; \
	else \
		echo -e "$(YELLOW)SSH key already exists at $(SSH_KEY_PATH)$(NC)"; \
	fi
	@$(MAKE) check-ssh-perms
# ---------------------------------------------------------------------------------#


# ---------------------------------------------------------------------------------#
# Use Terraform to setup cluster																									 #
# ---------------------------------------------------------------------------------#
.PHONY: tf-init
tf-init:
	@echo -e "$(GREEN)Initializing Terraform...$(NC)"
	cd $(TERRAFORM_DIR) && terraform init || { echo -e "$(RED)Failed to initialize Terraform$(NC)"; exit 1; }

.PHONY: tf-plan
tf-plan:
	@echo -e "$(GREEN)Planning Terraform changes...$(NC)"
	cd $(TERRAFORM_DIR) && terraform plan || { echo -e "$(RED)Failed to plan Terraform changes$(NC)"; exit 1; }

.PHONY: tf-apply
tf-apply:
	@echo -e "$(GREEN)Applying Terraform changes...$(NC)"
	cd $(TERRAFORM_DIR) && terraform apply -auto-approve || { echo -e "$(RED)Failed to apply Terraform changes$(NC)"; exit 1; }

.PHONY: tf-destroy
tf-destroy:
	@echo -e "$(GREEN)Destroying Terraform resources...$(NC)"
	cd $(TERRAFORM_DIR) && terraform destroy -auto-approve || { echo -e "$(RED)Failed to destroy Terraform resources$(NC)"; exit 1; }

.PHONY: tf-fmt
tf-fmt:
	@echo -e "$(GREEN)Formatting Terraform files...$(NC)"
	cd $(TERRAFORM_DIR) && terraform fmt -recursive || { echo -e "$(RED)Failed to format Terraform files$(NC)"; exit 1; }

.PHONY: tf-validate
tf-validate:
	@echo -e "$(GREEN)Validating Terraform configuration...$(NC)"
	cd $(TERRAFORM_DIR) && terraform validate || { echo -e "$(RED)Terraform validation failed$(NC)"; exit 1; }
# ---------------------------------------------------------------------------------#

# ---------------------------------------------------------------------------------#
# Use Ansible playbooks to deploy Jenkins server																	 #
# ---------------------------------------------------------------------------------#
.PHONY: ansible-deploy
ansible-deploy:
	@echo -e "$(GREEN)Running Ansible playbooks to create compute instance and deploy Jenkins...$(NC)"
	ansible-playbook $(ANSIBLE_DIR)/create_compute_instance.yaml || { echo -e "$(RED)Failed to create compute instance$(NC)"; exit 1; }
	ansible-playbook $(ANSIBLE_DIR)/deploy_jenkins.yaml || { echo -e "$(RED)Failed to deploy Jenkins$(NC)"; exit 1; }
	@echo -e "$(GREEN)Ansible playbooks executed successfully$(NC)"
# ---------------------------------------------------------------------------------#
