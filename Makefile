#  This makefile is for developers and is not required to run Cowrie

# The binary to build (just the basename).
MODULE := cowrie

# Where to push the docker image.
#REGISTRY ?= docker.pkg.github.com/cowrie/cowrie
REGISTRY ?= cowrie

IMAGE := $(REGISTRY)/$(MODULE)

IMAGENAME := cowrie/cowrie
TAG := latest
CONTAINERNAME := cowrie

.PHONY: all
all: build

.PHONY: build
build: Dockerfile ## Build Docker image
	docker build -t ${IMAGENAME}:${TAG} .

.PHONY: run
run: start ## Run Docker container

.PHONY: lint
lint: ## Lint Docker Container
	hadolint Dockerfile

.PHONY: push
push: build ## Push Docker image to Docker Hub
	@echo "Pushing image to GitHub Docker Registry...\n"
	docker push $(IMAGE):$(TAG)

.PHONY: start
start: create-volumes ## Start Docker container
	docker run -p 2222:2222/tcp \
		   -p 2223:2223/tcp \
		   -v cowrie-etc:/cowrie/cowrie-git/etc \
		   -v cowrie-var:/cowrie/cowrie-git/var \
		   -d \
	           --name ${CONTAINERNAME} ${IMAGENAME}:${TAG}

.PHONY: stop
stop: ## Stop Docker Container
	docker stop ${CONTAINERNAME}

.PHONY: rm
rm: stop ## Delete Docker Container
	docker rm ${CONTAINERNAME}

.PHONY: clean
clean: ## Clean
	docker rmi ${IMAGENAME}:${TAG}

.PHONY: shell
shell: ## Start shell in running Docker container
	docker exec -it ${CONTAINERNAME} bash

.PHONY: logs
logs: ## Show Docker container logs
	docker logs ${CONTAINERNAME}

.PHONY: ps
ps:
	docker ps -f name=${CONTAINERNAME}

.PHONY: status
status: ps ## List running Docker containers

.PHONY: ip
ip: ## List IP of running Docker container
	docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${CONTAINERNAME}

.PHONY: create-volumes
create-volumes:
	docker volume create cowrie-var
	docker volume create cowrie-etc

.DEFAULT_GOAL := help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
