# Makefile for collecting and installing requirements for nativeedge-plugins-sdk.
VENVS := $(shell pyenv virtualenvs --skip-aliases --bare | grep 'project\b')
CLOUDIFY_COMMON := fusion-common
CLOUDIFY_AGENT := fusion-agent
CLOUDIFY_MANAGER := fusion-manager
BRANCH := master
SHELL := /bin/bash
DOMAIN=${GH_TOKEN}@github.com/fusion-e

default:
	make download_from_git
	make setup_local_virtual_env
	make run_tests

compile:
	make download_from_git
	make setup_local_virtual_env

download_from_git:
	make download_cloudify_common
	make download_cloudify_agent
	make download_cloudify_manager

setup_local_virtual_env:
ifneq ($(VENVS),)
	@echo We have $(VENVS)
	pyenv virtualenv-delete -f project && pyenv deactivate
endif
	pyenv virtualenv 3.11 project

download_cloudify_common:
ifneq ($(wildcard ./${CLOUDIFY_COMMON}*),)
	@echo "Found ${CLOUDIFY_COMMON}."
else
	git clone https://${DOMAIN}/${CLOUDIFY_COMMON}.git ${HOME}/${CLOUDIFY_COMMON} && cd ${HOME}/${CLOUDIFY_COMMON} && git checkout ${BRANCH} && cd
endif

download_cloudify_agent:
ifneq ($(wildcard ./${CLOUDIFY_AGENT}*),)
	@echo "Found ${CLOUDIFY_AGENT}."
else
	git clone https://${DOMAIN}/${CLOUDIFY_AGENT}.git ${HOME}/${CLOUDIFY_AGENT} && cd ${HOME}/${CLOUDIFY_AGENT} && git checkout ${BRANCH} && cd
endif

download_cloudify_manager:
ifneq ($(wildcard ${CLOUDIFY_MANAGER}*),)
	@echo "Found ./${CLOUDIFY_MANAGER}."
else
	git clone https://${DOMAIN}/${CLOUDIFY_MANAGER}.git ${HOME}/${CLOUDIFY_MANAGER} && cd ${HOME}/${CLOUDIFY_MANAGER}/mgmtworker && git checkout ${BRANCH} && cd
endif

cleanup:
	pyenv virtualenv-delete -f project
	rm -rf ${CLOUDIFY_MANAGER} ${CLOUDIFY_AGENT} ${CLOUDIFY_COMMON}

run_tests:
	@echo "Starting executing the tests."
	HOME=${HOME} VIRTUAL_ENV=${HOME}/.pyenv/${VENVS} tox

clrf:
	@find . \( -path ./.tox -prune -o -path ./.git -prune \) -o -type f -exec dos2unix {} \;

wheels:
	@echo "Creating wheels..."
	@pip wheel ${HOME}/${CLOUDIFY_COMMON}/ -w /workspace/build/ --find-links /workspace/build
	@pip wheel ${HOME}/${CLOUDIFY_AGENT}/ -w /workspace/build/ --find-links /workspace/build
	@pip wheel ${HOME}/${CLOUDIFY_MANAGER}/mgmtworker -w /workspace/build/ --find-links /workspace/build
