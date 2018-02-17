EDITOR=vim

include /etc/os-release

all: download install-prerequisites regconfig build


download:
	wget https://downloads.tableau.com/esdalt/10.5.0/tableau-server-10-5-0.x86_64.rpm
	wget https://downloads.tableau.com/esdalt/10.5.0/tableau-tabcmd-10-5-0.noarch.rpm

install-prerequisites:
ifeq ("$(wildcard /usr/bin/docker)","")
        @echo install docker-ce, still to be tested
        sudo apt-get update
        sudo apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common

        curl -fsSL https://download.docker.com/linux/${ID}/gpg | sudo apt-key add -
        sudo add-apt-repository \
                "deb https://download.docker.com/linux/ubuntu \
                `lsb_release -cs` \
                stable"
        sudo apt-get update
        sudo apt-get install -y docker-ce
        sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
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

