#  This makefile is for developers and is not required to run Cowrie

# The binary to build (just the basename).
MODULE := cowrie

# Where to push the docker image.
REGISTRY ?= docker.pkg.github.com/cowrie/cowrie

IMAGE := $(REGISTRY)/$(MODULE)

IMAGENAME := cowrie
TAG := devel
CONTAINERNAME := cowrie

.PHONY: all
all: build

.PHONY: build
build: Dockerfile
	docker build -t ${IMAGENAME}:${TAG} .

.PHONY: run
run: start

.PHONY: push
push: build-prod
	@echo "Pushing image to GitHub Docker Registry...\n"
	@docker push $(IMAGE):$(VERSION)

.PHONY: start
start: create-volumes
	docker run -p 2222:2222/tcp \
		   -p 2223:2223/tcp \
		   -v cowrie-etc:/cowrie/cowrie-git/etc \
		   -v cowrie-var:/cowrie/cowrie-git/var \
		   -d \
	           --name ${CONTAINERNAME} ${IMAGENAME}:${TAG}

.PHONY: stop
stop:
	docker stop ${CONTAINERNAME}

.PHONY: rm
rm: stop
	docker rm ${CONTAINERNAME}

.PHONY: clean
clean:
	docker rmi ${IMAGENAME}:${TAG}

.PHONY: shell
shell:
	docker exec -it ${CONTAINERNAME} bash

.PHONY: logs
logs:
	docker logs ${CONTAINERNAME}

.PHONY: ps
ps:
	docker ps -f name=${CONTAINERNAME}

.PHONY: status
status: ps

.PHONY: ip
ip:
	docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${CONTAINERNAME}

.PHONY: create-volumes
create-volumes:
	docker volume create cowrie-var
	docker volume create cowrie-etc
