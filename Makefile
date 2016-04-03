#Makefile for Docker container control

# define docker container
CONTAINER_REPO = hobbsau/tvheadend
CONTAINER_DATA = tvheadend-data
CONTAINER_RUN = tvheadend-service

# define the directory containing the original config files to be copied to the data container 
#CONFIG_ORIG = /srv/tvheadend/config

# define the exportable volumes for the data container
CONFIG_VOL = /config
DATA_VOL = /recordings

# This should point to any host directories containing the tvheadend config. The host directory must be owned by UID:GID 100:65533. The format is /host/directory:
CONFIG_BIND = /srv/tvheadend/config:
DATA_BIND = 

TRIGGER_URL = https://registry.hub.docker.com/u/hobbsau/tvheadend/trigger/f774eaab-19a9-4144-ac60-596199fa77fa/

build:
	@curl --data build=true -X POST $(TRIGGER_URL) 
	@sleep 60
	@docker pull $(CONTAINER_REPO)

create-data:
	@if [ -z "`docker ps -a -q -f name=$(CONTAINER_DATA)`" ]; \
	then \
		docker pull $(CONTAINER_REPO); \
		docker create \
 		--name $(CONTAINER_DATA) \
 		-v $(CONFIG_BIND)$(CONFIG_VOL) \
 		-v $(DATA_BIND)$(DATA_VOL) \
 		$(CONTAINER_REPO) \
 		/bin/true; \
	else \
		echo "Container already exists"; \
	fi


clean-data:
	@if [ -z "`docker ps -a -q -f name=$(CONTAINER_DATA)`" ]; \
        then \
		echo "Nothing to remove as container $(CONTAINER_DATA) doesn't exist!"; \
	else \
		echo "Removing container..."; \
		docker rm -v $(CONTAINER_DATA); \
	fi	

run: create-data
	@if [ -z "`docker ps -q -f name=$(CONTAINER_RUN)`" ]; \
	then \
		docker pull $(CONTAINER_REPO); \
		docker run -d \
 		--restart=always \
 		--net="host" \
 		--volumes-from $(CONTAINER_DATA) \
 		--name $(CONTAINER_RUN) \
 		$(CONTAINER_REPO); \
	else \
		echo "$(CONTAINER_RUN) already running!"; \
	fi
stop:
	@if [ -z "`docker ps -q -f name=$(CONTAINER_RUN)`" ]; \
        then \
		echo "Nothing to stop as container $(CONTAINER_RUN) isn't running!"; \
	else \
	docker stop $(CONTAINER_RUN); \
	fi

clean: stop
	@if [ -z "`docker ps -a -q -f name=$(CONTAINER_RUN)`" ]; \
        then \
		echo "Nothing to remove as container $(CONTAINER_RUN) doesn't exist!"; \
	else \
	echo "Removing container..."; \
	docker rm $(CONTAINER_RUN); \
	fi

upgrade: clean build run
