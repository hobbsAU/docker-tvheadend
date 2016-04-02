#Makefile for Docker container control

# define docker container
CONTAINER_REPO = hobbsau/tvheadend
CONTAINER_DATA = tvheadend-data
CONTAINER_RUN = tvheadend-service

# define the directory containing the original config files to be copied to the data container 
#CONFIG_ORIG = /srv/tvheadend/config

# define the exportable volumes
CONFIG_VOL = /config
DATA_VOL = /recordings
CONFIG_BIND = /srv/tvheadend/config:
DATA_BIND = 

TRIGGER_URL = https://registry.hub.docker.com/u/hobbsau/tvheadend/trigger/f774eaab-19a9-4144-ac60-596199fa77fa/

build:
	@curl --data build=true -X POST $(TRIGGER_URL) 

create-data:
	if [ -z "`docker ps -a -q -f name=$(CONTAINER_DATA)`" ]; \
	then \
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
		echo "Container $(CONTAINER_DATA) doesn't exist!"; \
	else \
		docker rm -v $(CONTAINER_DATA); \
	fi	

run: create-data
	@docker run -d \
 		--restart=always \
 		--net="host" \
 		--volumes-from $(CONTAINER_DATA) \
 		--name $(CONTAINER_RUN) \
 		$(CONTAINER_REPO)

stop:
	@docker stop $(CONTAINER_RUN)

clean: stop
	@docker rm $(CONTAINER_RUN)
