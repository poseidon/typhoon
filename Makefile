.PHONY: fmt lint test

TERRAFORMFMT_FILES?=.

fmt:
	terraform fmt $(TERRAFORMFMT_FILES)

lint:
	@echo "terraform fmt $(TERRAFORMFMT_FILES)"
	@lint_res=$$(terraform fmt $(TERRAFORMFMT_FILES)) ; if [ -n "$$lint_res" ]; then \
		echo ""; \
		echo "Terraform fmt found style issues. Please check the reported issues"; \
		echo "and fix them if necessary before submitting the code for review:"; \
		echo "$$lint_res"; \
		exit 1; \
	fi

test: lint
