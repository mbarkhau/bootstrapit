SHELL := /bin/bash
.SHELLFLAGS := -O extglob -eo pipefail -c
.DEFAULT_GOAL := help
.SUFFIXES:


DOCKER_IMAGE_VERSION := $(shell date -u +'%Y%m%dt%H%M%S')


## Short help message for each task.
.PHONY: help
help:
	@awk '{ \
			if ($$0 ~ /^.PHONY: [a-zA-Z\-\_0-9]+$$/) { \
				helpCommand = substr($$0, index($$0, ":") + 2); \
				if (helpMessage) { \
					printf "\033[36m%-20s\033[0m %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^[a-zA-Z\-\_0-9.]+:/) { \
				helpCommand = substr($$0, 0, index($$0, ":")); \
				if (helpMessage) { \
					printf "\033[36m%-20s\033[0m %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^##/) { \
				if (! (helpMessage)) { \
					helpMessage = substr($$0, 3); \
				} \
			} else { \
				if (helpMessage) { \
					print "                     "helpMessage \
				} \
				helpMessage = ""; \
			} \
		}' \
		$(MAKEFILE_LIST)


## Build docker images for downstream projects
.PHONY: build_docker
build_docker:
	docker build \
		--file docker_root.Dockerfile \
		--tag registry.gitlab.com/mbarkhau/bootstrapit/root:$(DOCKER_IMAGE_VERSION) \
		--tag registry.gitlab.com/mbarkhau/bootstrapit/root \
		.;

	docker build \
		--file docker_env_builder.Dockerfile \
		--tag registry.gitlab.com/mbarkhau/bootstrapit/env_builder:$(DOCKER_IMAGE_VERSION) \
		--tag registry.gitlab.com/mbarkhau/bootstrapit/env_builder \
		.;

	docker push registry.gitlab.com/mbarkhau/bootstrapit/root;
	docker push registry.gitlab.com/mbarkhau/bootstrapit/env_builder;
