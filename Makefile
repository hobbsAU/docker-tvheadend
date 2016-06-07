#Makefile for Docker container control

# Define container repo and runtime name
CONTAINER_REPO = hobbsau/tvheadend
CONTAINER_RUN = tvheadend-service
CONTAINER_DATA = tvheadend-data


# Define the directory containing the original config files to be copied to the data container 
#CONFIG_ORIG = /srv/tvheadend/config

# Define the exportable volumes for the container
CONFIG_VOL = /config
DATA_VOL = /recordings

# This should point to the Docker host directory containing the config. The host directory must be owned by UID:GID 1000:1000. The format is '/host/directory:'
CONFIG_BIND = /srv/tvheadend/config:
DATA_BIND = /srv/tvheadend/recordings:

# URL for triggering a rebuild
TRIGGER_URL = https://registry.hub.docker.com/u/hobbsau/tvheadend/trigger/f774eaab-19a9-4144-ac60-596199fa77fa/

# Trigger a remote initiated rebuild
build:
	echo "Rebuilding repository $(CONTAINER_REPO) ..."; 
	@curl --data build=true -X POST $(TRIGGER_URL) 

# Instantiate data container
create-data:
	@if [ -z "`docker ps -a -q -f name=$(CONTAINER_DATA)`" ]; \
	then \
		echo "Checking for latest container..."; \
		docker pull $(CONTAINER_REPO); \
		echo "Creating data container..."; \
		docker create \
 		--name $(CONTAINER_DATA) \
 		-v $(CONFIG_BIND)$(CONFIG_VOL) \
 		-v $(DATA_BIND)$(DATA_VOL) \
 		$(CONTAINER_REPO) \
 		/bin/true; \
	else \
		echo "Data container $(CONTAINER_DATA) already exists"; \
	fi

# Destroy (delete) data container
clean-data:
	@if [ -z "`docker ps -a -q -f name=$(CONTAINER_DATA)`" ]; \
        then \
		echo "Nothing to remove as container $(CONTAINER_DATA) doesn't exist!"; \
	else \
		echo "Removing container..."; \
		docker rm -v $(CONTAINER_DATA); \
	fi	

# Intantiate service continer and start it
run: create-data
	@if [ -z "`docker ps -a -q -f name=$(CONTAINER_RUN)`" ]; \
	then \
		echo "Checking for latest container..."; \
		docker pull $(CONTAINER_REPO); \
		echo "Creating and starting container..."; \
		docker run -d \
 		--restart=always \
 		--net="host" \
 		--volumes-from $(CONTAINER_DATA) \
 		--name $(CONTAINER_RUN) \
 		$(CONTAINER_REPO); \
	else \
		echo "$(CONTAINER_RUN) is already running or a stopped container by the same name exists!"; \
		echo "Please try 'make clean' and then 'make run'"; \
	fi

# Start the service container. 
start:
	@if [ -z "`docker ps -q -f name=$(CONTAINER_RUN)`" ] && [ -n "`docker ps -a -q -f name=$(CONTAINER_RUN)`" ]; \
        then \
		echo "Starting container..."; \
		docker start $(CONTAINER_RUN); \
	else \
		echo "Container $(CONTAINER_RUN) doesn't exist or is already running!"; \
	fi

# Stop the service container. 
stop:
	@if [ -z "`docker ps -q -f name=$(CONTAINER_RUN)`" ]; \
        then \
		echo "Nothing to stop as container $(CONTAINER_RUN) is not running!"; \
	else \
		echo "Stopping container..."; \
		docker stop $(CONTAINER_RUN); \
	fi

# Service container is ephemeral so clean should be used with impunity.
clean: stop
	@if [ -z "`docker ps -a -q -f name=$(CONTAINER_RUN)`" ]; \
        then \
		echo "Nothing to remove as container $(CONTAINER_RUN) does not exist!"; \
	else \
		echo "Removing container..."; \
		docker rm $(CONTAINER_RUN); \
	fi

# Upgrade the container - may not work if rebuild takes too long
upgrade: build clean run






