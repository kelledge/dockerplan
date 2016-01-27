#
# Useful variables
#
ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
TIMESTAMP := $(shell date +%s)

#
# Docker variables
#
DOCKER_CID_PATH  := $(ROOT_DIR)/.cid
DOCKER_CID       := $(shell cat $(DOCKER_CID_PATH) 2>/dev/null)

DOCKER_IMAGE     := assemble-$(PROJECT_NAME)
DOCKER_TAG       ?= latest
DOCKER_WORK_DIR  := /assemble
DOCKER_BIND_VOL  := $(ROOT_DIR):$(DOCKER_WORK_DIR)
DOCKER_CMD       := /bin/sleep infinity
DOCKER_OPTIONS   ?=
DOCKER           := $(shell which docker)
DOCKER_SHELL     := $(DOCKER) exec $(DOCKER_CID) /bin/bash
DOCKER_SHELL_TTY := $(DOCKER) exec -it $(DOCKER_CID) /bin/bash

$(DOCKER_CID_PATH):
	@$(DOCKER) run -d $(DOCKER_ENVS) \
		-w $(DOCKER_WORK_DIR) \
		-v $(DOCKER_BIND_VOL) \
		$(DOCKER_OPTIONS) \
		$(DOCKER_IMAGE):$(DOCKER_TAG) \
		$(DOCKER_CMD) > $(DOCKER_CID_PATH)

#
# Container lifecycle
#
up: $(DOCKER_CID_PATH)

down:
	-@$(DOCKER) kill $(DOCKER_CID)
	-@$(DOCKER) rm $(DOCKER_CID)
	-@rm -f $(DOCKER_CID_PATH)

refresh: down up

#
# Image lifecycle
#
create:
	@$(DOCKER) build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

destroy:
	@$(DOCKER) rmi $(DOCKER_IMAGE):$(DOCKER_TAG)

reload: down create up

#
# Tools
#
shell: SHELL := $(DOCKER_SHELL_TTY)
shell:
	@bash -l
