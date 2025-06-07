# Default target
.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "Available targets:"
	@grep -E '^\.[PHONY]+: [a-zA-Z0-9_-]+.*$$' $(MAKEFILE_LIST) | awk '{print "  make " $$2}'

# Run the app without Docker Compose
.PHONY: run
run:
	@echo "Running the app without Docker Compose..."
	cd app && uvicorn main:app --host 0.0.0.0 --port 8000

# Install Python dependencies
.PHONY: install
install:
	@echo "Creating virtual environment..."
	python3 -m venv .venv
	@echo "Installing dependencies..."
	. .venv/bin/activate && cd app && pip install -r requirements.txt


.PHONY: clean
clean:
	@echo "Cleaning up..."
	find app -type d -name "__pycache__" -exec rm -rf {} +
	@echo "Removing virtual environment..."
	rm -rf .venv


