# Get the current date and time in YYYYMMDD:HH:mm:ss format
# This needs to be OS-dependent.

# Default for Linux/macOS
CURRENT_DATETIME := $(shell date +%Y%m%d:%H:%M:%S)

# Override for Windows using PowerShell (more reliable for formatting)
ifeq ($(OS),Windows_NT)
    CURRENT_DATETIME := $(shell powershell -Command "Get-Date -Format 'yyyyMMdd:HH:mm:ss'")
endif

.PHONY: deploy

deploy:
	@echo "Staging all changes..."
	git add .
	@echo "Creating commit with message: $(CURRENT_DATETIME)..."
	git commit -m "$(CURRENT_DATETIME)"
	@echo "Pushing changes..."
	git push
	@echo "Deployment complete."

# You can add a simple test target for the date if you want
.PHONY: show_date
show_date:
	@echo "Calculated datetime: $(CURRENT_DATETIME)"




.PHONY: help  ## Display this message
help:
	@grep -E \
		'^.PHONY: .*?## .*$$' $(MAKEFILE_LIST) | \
		sort | \
		awk 'BEGIN {FS = ".PHONY: |## "}; {printf "\033[36m%-19s\033[0m %s\n", $$2, $$3}'