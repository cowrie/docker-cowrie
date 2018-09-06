IMAGENAME = cowrie
CONTAINERNAME= cowrie

all: Dockerfile
	docker build -t ${IMAGENAME} .

run: start

start:
	docker run -p 2222:2222/tcp -p 2223:2223/tcp -d --name ${CONTAINERNAME} ${IMAGENAME}

stop:
	docker stop ${CONTAINERNAME}
	docker rm ${CONTAINERNAME}

clean:
	docker rmi ${IMAGENAME}

shell:
	docker exec -it ${CONTAINERNAME} bash

logs:
	docker logs ${CONTAINERNAME}

ps:
	docker ps -f name=${CONTAINERNAME}

status: ps

ip:
	docker inspect ${CONTAINERNAME} | jq '..|.IPAddress?' | grep -v null | sort -u

