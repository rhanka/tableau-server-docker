EDITOR=vim

all: install-prerequisites regconfig build

install-prerequisites:
ifeq ("$(wildcard /usr/bin/docker)","")
	@echo install docker-ce, still to be tested
	sudo apt-get update
	sudo apt-get install \
    	apt-transport-https \
    	ca-certificates \
    	curl \
    	software-properties-common

	curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
	sudo add-apt-repository \
   		"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   		$(lsb_release -cs) \
   		stable"
   	sudo apt-get update
		sudo apt-get install -y docker-ce
endif

network: 
	@docker network create latelier 2> /dev/null; true


build:
	docker build -t tableau-server .

up: network
	docker-compose up -d

down:
	docker-compose down

restart: down up


clean:
	docker ps -aq --no-trunc | xargs docker rm

exec:
	docker exec -ti `docker ps | grep tableau-server |head -1 | awk -e '{print $$1}'` /bin/bash


config/registration_file.json: 
	cp config/registration_file.json.templ config/registration_file.json
	$(EDITOR) config/registration_file.json

regconfig: config/registration_file.json

stop:
	docker stop `docker ps | grep tableau-server |head -1| awk -e '{print $$1}'`

