# Self-Documented Makefile see https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html

.DEFAULT_GOAL := help

PYTHON 			:= /usr/bin/env python
PYTHON_VERSION  := $(PYTHON) --version
MANAGE_PY 		:= $(PYTHON) manage.py
PYTHON_PIP  	:= /usr/bin/env pip
PIP_COMPILE 	:= /usr/bin/env pip-compile
PART 			:= patch
PACKAGE_VERSION := $(shell $(PYTHON) setup.py --version)

# Put it first so that "make" without argument is like "make help".
help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-32s-\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: help

guard-%: ## Checks that env var is set else exits with non 0 mainly used in CI;
	@if [ -z '${${*}}' ]; then echo 'Environment variable $* not set' && exit 1; fi

# --------------------------------------------------------
# ------- Python package (pip) management commands -------
# --------------------------------------------------------

clean-build: ## Clean project build artifacts.
	@echo "Removing build assets..."
	@$(PYTHON) setup.py clean
	@rm -rf build/
	@rm -rf dist/
	@rm -rf *.egg-info

test:
	@echo "Running `$(PYTHON_VERSION)` test..."
	@$(MANAGE_PY) test -v 3 --noinput --failfast

install: clean-build  ## Install project dependencies.
	@echo "Installing project in dependencies..."
	@$(PYTHON_PIP) install -r requirements.txt

install-lint: clean-build  ## Install lint extra dependencies.
	@echo "Installing lint extra requirements..."
	@$(PYTHON_PIP) install -e .'[lint]'

install-test: clean-build clean-test-all ## Install test extra dependencies.
	@echo "Installing test extra requirements..."
	@$(PYTHON_PIP) install -e .'[test]'

install-dev: clean-build  ## Install development extra dependencies.
	@echo "Installing development requirements..."
	@$(PYTHON_PIP) install -e .'[development]' -r requirements.txt

install-deploy:
	@echo "Installing deploy extra requirements..."
	@$(PYTHON_PIP) install -q -e .'[deploy]'

update-requirements:  ## Updates the requirement.txt adding missing package dependencies
	@echo "Syncing the package requirements.txt..."
	@$(PIP_COMPILE)

tag-build:
	@git tag v$(PACKAGE_VERSION)

upload-to-pypi:  ## Release project to pypi
	@$(PYTHON_PIP) install -U pip twine setuptools
	@$(PYTHON) setup.py sdist bdist_wheel
	@twine upload dist/*


# ----------------------------------------------------------
# ---------- Upgrade project version (bumpversion)  --------
# ----------------------------------------------------------
release-to-pypi: clean-build install-deploy guard-PART  ## Bump the project version (using the $PART env: defaults to 'patch').
	@echo "Increasing project '$(PART)' version..."
	@bump2version --verbose $(PART)
	@git-changelog . > CHANGELOG.md
	@git commit -am "Updated CHANGELOG.md."
	@$(MAKE) start-release

start-release: setup.py
	@echo "Creating release..."
	@eval PACKAGE_VERSION=$(shell $(PYTHON) setup.py --version)
	@echo "Upgrading to $(PACKAGE_VERSION)..."
	@git flow release start "$(PACKAGE_VERSION)"
	# Run this again this seems to be a bug
	@git-changelog . > CHANGELOG.md
	@GIT_MERGE_AUTOEDIT=no git flow release finish -m "Upgraded to:" "$(strip $(PACKAGE_VERSION))"
	@git push --tags
	@git push origin develop
	@git push origin master

# ----------------------------------------------------------
# --------- Run project Test -------------------------------
# ----------------------------------------------------------
nox:  ## Run nox test
	@echo "Running nox..."
	@nox -x --report status.json

clean-test-all: clean-build  ## Clean build and test assets.
	@rm -rf .tox/
	@rm -rf test-results
	@rm -rf .pytest_cache/
	@rm -f test.db


# -----------------------------------------------------------
# --------- Run autopep8 ------------------------------------
# -----------------------------------------------------------
run-autopep8:  ## Run autopep8 with inplace for check_constraint package.
	@autopep8 -ri check_constraint
