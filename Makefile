SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c

VENV_BIN := $(CURDIR)/.venv/bin
TERRAFORM_ENV := terraform/envs/dev
TERRAFORM_ENV_FILES := $(shell find $(TERRAFORM_ENV) -type f -name '*.tf' -print -quit 2>/dev/null)

export PATH := $(VENV_BIN):$(PATH)

.PHONY: fmt lint validate plan

fmt:
	terraform fmt -recursive terraform

lint:
	pre-commit run --all-files

validate:
	@if [[ -z "$(TERRAFORM_ENV_FILES)" ]]; then \
		printf '%s\n' 'SKIP: terraform validate (no Terraform files in the dev environment yet)'; \
	else \
		terraform -chdir=$(TERRAFORM_ENV) init -backend=false -input=false; \
		terraform -chdir=$(TERRAFORM_ENV) validate; \
	fi

plan:
	@if [[ -z "$(TERRAFORM_ENV_FILES)" ]]; then \
		printf '%s\n' 'SKIP: terraform plan (no Terraform files in the dev environment yet)'; \
	else \
		terraform -chdir=$(TERRAFORM_ENV) plan -input=false; \
	fi