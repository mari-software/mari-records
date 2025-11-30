ENV_FILE := .env

# Discover all features dynamically
APPS := $(shell find apps -type d -mindepth 1 -maxdepth 1 -exec basename {} \; 2>/dev/null | sort)
SERVICES := $(shell find services -type d -mindepth 1 -maxdepth 1 -exec basename {} \; 2>/dev/null | sort)
GATEWAYS := $(shell find gateways -type d -mindepth 1 -maxdepth 1 -exec basename {} \; 2>/dev/null | sort)

.PHONY: dev build prod stop clean help

help:
	@echo "Available targets:"
	@echo "  make dev    - Run all apps, services, and gateways in development mode"
	@echo "  make build  - Build all apps, services, and gateways"
	@echo "  make prod   - Run all apps, services, and gateways in production mode"
	@echo "  make stop   - Stop all running apps, services, and gateways"
	@echo "  make clean  - Clean build artifacts"

# Development: Run all features concurrently
dev:
	@echo "Starting all features in development mode..."
	@for app in $(APPS); do \
		ENV_PREFIX=$$(echo $$app | tr '[:lower:]' '[:upper:]' | sed 's/-/_/g'); \
		ENV_KEY="$${ENV_PREFIX}_DEV_PORT"; \
		EXPORT_KEY="$${ENV_PREFIX}_PORT"; \
		PORT=$$(grep "^$${ENV_KEY}=" $(ENV_FILE) 2>/dev/null | cut -d '=' -f2); \
		if [ -n "$$PORT" ]; then \
			echo "Starting $$app with $${EXPORT_KEY}=$$PORT"; \
			env "$${EXPORT_KEY}=$$PORT" go run apps/$$app/cmd/main.go & \
		fi; \
	done
	@for svc in $(SERVICES); do \
		ENV_PREFIX=$$(echo $$svc | tr '[:lower:]' '[:upper:]' | sed 's/-/_/g'); \
		ENV_KEY="$${ENV_PREFIX}_DEV_PORT"; \
		EXPORT_KEY="$${ENV_PREFIX}_PORT"; \
		PORT=$$(grep "^$${ENV_KEY}=" $(ENV_FILE) 2>/dev/null | cut -d '=' -f2); \
		if [ -n "$$PORT" ]; then \
			echo "Starting $$svc with $${EXPORT_KEY}=$$PORT"; \
			env "$${EXPORT_KEY}=$$PORT" go run services/$$svc/cmd/main.go & \
		fi; \
	done
	@for gw in $(GATEWAYS); do \
		ENV_PREFIX=$$(echo $$gw | tr '[:lower:]' '[:upper:]' | sed 's/-/_/g'); \
		ENV_KEY="$${ENV_PREFIX}_DEV_PORT"; \
		EXPORT_KEY="$${ENV_PREFIX}_PORT"; \
		PORT=$$(grep "^$${ENV_KEY}=" $(ENV_FILE) 2>/dev/null | cut -d '=' -f2); \
		if [ -n "$$PORT" ]; then \
			echo "Starting $$gw with $${EXPORT_KEY}=$$PORT"; \
			env "$${EXPORT_KEY}=$$PORT" go run gateways/$$gw/cmd/main.go & \
		fi; \
	done
	@echo "All features started. Press Ctrl+C to stop all services."
	@wait

# Build: Build all features
build:
	@echo "Building all features..."
	@mkdir -p build
	@for app in $(APPS); do \
		ENV_PREFIX=$$(echo $$app | tr '[:lower:]' '[:upper:]' | sed 's/-/_/g'); \
		ENV_KEY="$${ENV_PREFIX}_BUILD_PORT"; \
		EXPORT_KEY="$${ENV_PREFIX}_PORT"; \
		PORT=$$(grep "^$${ENV_KEY}=" $(ENV_FILE) 2>/dev/null | cut -d '=' -f2); \
		if [ -n "$$PORT" ]; then \
			echo "Building $$app..."; \
			env "$${EXPORT_KEY}=$$PORT" go build -o build/$$app apps/$$app/cmd/main.go; \
		fi; \
	done
	@for svc in $(SERVICES); do \
		ENV_PREFIX=$$(echo $$svc | tr '[:lower:]' '[:upper:]' | sed 's/-/_/g'); \
		ENV_KEY="$${ENV_PREFIX}_BUILD_PORT"; \
		EXPORT_KEY="$${ENV_PREFIX}_PORT"; \
		PORT=$$(grep "^$${ENV_KEY}=" $(ENV_FILE) 2>/dev/null | cut -d '=' -f2); \
		if [ -n "$$PORT" ]; then \
			echo "Building $$svc..."; \
			env "$${EXPORT_KEY}=$$PORT" go build -o build/$$svc services/$$svc/cmd/main.go; \
		fi; \
	done
	@for gw in $(GATEWAYS); do \
		ENV_PREFIX=$$(echo $$gw | tr '[:lower:]' '[:upper:]' | sed 's/-/_/g'); \
		ENV_KEY="$${ENV_PREFIX}_BUILD_PORT"; \
		EXPORT_KEY="$${ENV_PREFIX}_PORT"; \
		PORT=$$(grep "^$${ENV_KEY}=" $(ENV_FILE) 2>/dev/null | cut -d '=' -f2); \
		if [ -n "$$PORT" ]; then \
			echo "Building $$gw..."; \
			env "$${EXPORT_KEY}=$$PORT" go build -o build/$$gw gateways/$$gw/cmd/main.go; \
		fi; \
	done
	@echo "Build complete!"

# Production: Run all features with PROD env vars
prod:
	@echo "Starting all features in production mode..."
	@for app in $(APPS); do \
		ENV_PREFIX=$$(echo $$app | tr '[:lower:]' '[:upper:]' | sed 's/-/_/g'); \
		ENV_KEY="$${ENV_PREFIX}_PROD_PORT"; \
		EXPORT_KEY="$${ENV_PREFIX}_PORT"; \
		PORT=$$(grep "^$${ENV_KEY}=" $(ENV_FILE) 2>/dev/null | cut -d '=' -f2); \
		if [ -n "$$PORT" ]; then \
			echo "Starting $$app with $${EXPORT_KEY}=$$PORT"; \
			env "$${EXPORT_KEY}=$$PORT" go run apps/$$app/cmd/main.go & \
		fi; \
	done
	@for svc in $(SERVICES); do \
		ENV_PREFIX=$$(echo $$svc | tr '[:lower:]' '[:upper:]' | sed 's/-/_/g'); \
		ENV_KEY="$${ENV_PREFIX}_PROD_PORT"; \
		EXPORT_KEY="$${ENV_PREFIX}_PORT"; \
		PORT=$$(grep "^$${ENV_KEY}=" $(ENV_FILE) 2>/dev/null | cut -d '=' -f2); \
		if [ -n "$$PORT" ]; then \
			echo "Starting $$svc with $${EXPORT_KEY}=$$PORT"; \
			env "$${EXPORT_KEY}=$$PORT" go run services/$$svc/cmd/main.go & \
		fi; \
	done
	@for gw in $(GATEWAYS); do \
		ENV_PREFIX=$$(echo $$gw | tr '[:lower:]' '[:upper:]' | sed 's/-/_/g'); \
		ENV_KEY="$${ENV_PREFIX}_PROD_PORT"; \
		EXPORT_KEY="$${ENV_PREFIX}_PORT"; \
		PORT=$$(grep "^$${ENV_KEY}=" $(ENV_FILE) 2>/dev/null | cut -d '=' -f2); \
		if [ -n "$$PORT" ]; then \
			echo "Starting $$gw with $${EXPORT_KEY}=$$PORT"; \
			env "$${EXPORT_KEY}=$$PORT" go run gateways/$$gw/cmd/main.go & \
		fi; \
	done
	@echo "All features started. Press Ctrl+C to stop all services."
	@wait

# Stop: Kill all running features
stop:
	@echo "Stopping all running features..." || true
	@for app in $(APPS); do \
		echo "Stopping $$app..." || true; \
		for pid in $$(pgrep -f "go run apps/$$app/cmd/main.go" 2>/dev/null); do \
			kill -TERM $$pid 2>/dev/null || kill -9 $$pid 2>/dev/null || true; \
		done || true; \
	done || true
	@for svc in $(SERVICES); do \
		echo "Stopping $$svc..." || true; \
		for pid in $$(pgrep -f "go run services/$$svc/cmd/main.go" 2>/dev/null); do \
			kill -TERM $$pid 2>/dev/null || kill -9 $$pid 2>/dev/null || true; \
		done || true; \
	done || true
	@for gw in $(GATEWAYS); do \
		echo "Stopping $$gw..." || true; \
		for pid in $$(pgrep -f "go run gateways/$$gw/cmd/main.go" 2>/dev/null); do \
			kill -TERM $$pid 2>/dev/null || kill -9 $$pid 2>/dev/null || true; \
		done || true; \
	done || true
	@# Also kill processes by port from .env file
	@for app in $(APPS); do \
		ENV_PREFIX=$$(echo $$app | tr '[:lower:]' '[:upper:]' | sed 's/-/_/g'); \
		for mode in DEV PROD; do \
			ENV_KEY="$${ENV_PREFIX}_$${mode}_PORT"; \
			PORT=$$(grep "^$${ENV_KEY}=" $(ENV_FILE) 2>/dev/null | cut -d '=' -f2 | sed 's/^://'); \
			if [ -n "$$PORT" ]; then \
				PID=$$(lsof -ti:$$PORT 2>/dev/null | head -1); \
				if [ -n "$$PID" ]; then \
					echo "Stopping process on port $$PORT (PID: $$PID)"; \
					kill -TERM $$PID 2>/dev/null || kill -9 $$PID 2>/dev/null || true; \
				fi; \
			fi; \
		done; \
	done
	@for svc in $(SERVICES); do \
		ENV_PREFIX=$$(echo $$svc | tr '[:lower:]' '[:upper:]' | sed 's/-/_/g'); \
		for mode in DEV PROD; do \
			ENV_KEY="$${ENV_PREFIX}_$${mode}_PORT"; \
			PORT=$$(grep "^$${ENV_KEY}=" $(ENV_FILE) 2>/dev/null | cut -d '=' -f2 | sed 's/^://'); \
			if [ -n "$$PORT" ]; then \
				PID=$$(lsof -ti:$$PORT 2>/dev/null | head -1); \
				if [ -n "$$PID" ]; then \
					echo "Stopping process on port $$PORT (PID: $$PID)"; \
					kill -TERM $$PID 2>/dev/null || kill -9 $$PID 2>/dev/null || true; \
				fi; \
			fi; \
		done; \
	done
	@for gw in $(GATEWAYS); do \
		ENV_PREFIX=$$(echo $$gw | tr '[:lower:]' '[:upper:]' | sed 's/-/_/g'); \
		for mode in DEV PROD; do \
			ENV_KEY="$${ENV_PREFIX}_$${mode}_PORT"; \
			PORT=$$(grep "^$${ENV_KEY}=" $(ENV_FILE) 2>/dev/null | cut -d '=' -f2 | sed 's/^://'); \
			if [ -n "$$PORT" ]; then \
				PID=$$(lsof -ti:$$PORT 2>/dev/null | head -1); \
				if [ -n "$$PID" ]; then \
					echo "Stopping process on port $$PORT (PID: $$PID)"; \
					kill -TERM $$PID 2>/dev/null || kill -9 $$PID 2>/dev/null || true; \
				fi; \
			fi; \
		done; \
	done
	@# Wait a moment for processes to terminate gracefully
	@sleep 0.5 2>/dev/null || sleep 1
	@# Force kill any remaining processes by pattern
	@for pid in $$(pgrep -f "apps/.*/cmd/main.go" 2>/dev/null); do \
		kill -9 $$pid 2>/dev/null || true; \
	done
	@for pid in $$(pgrep -f "services/.*/cmd/main.go" 2>/dev/null); do \
		kill -9 $$pid 2>/dev/null || true; \
	done
	@for pid in $$(pgrep -f "gateways/.*/cmd/main.go" 2>/dev/null); do \
		kill -9 $$pid 2>/dev/null || true; \
	done
	@echo "All features stopped!" || true
	@exit 0

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf build/
	@echo "Clean complete!"
