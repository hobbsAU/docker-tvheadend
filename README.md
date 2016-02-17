# docker-tvheadend [![Docker Pulls](https://img.shields.io/docker/pulls/hobbsau/docker-tvheadend.svg)](https://hub.docker.com/r/hobbsau/docker-tvheadend/)

Run tvheadend from a docker container

## Install
```sh
docker pull hobbsau/tvheadend
```

## Usage

First let's setup the data container that will map the config directory from the host to the container as well as the recordings directory. This container will provide persistent storage.
```sh
$ docker create \
 --name tvheadend-data \
 -v <hostdir>:/config \
 -v <hostdir>:/recordings \
 hobbsau/tvheadend \
 /bin/true
```  

Example using my host and the /srv/tvheadend location on my host:
```sh
$ sudo docker create --name tvheadend-data -v /srv/tvheadend/config:/config -v /srv/tvheadend/recordings:/recordings hobbsau/tvheadend
```  

Next we run the tvheadend-service and this will automatically map the volumes within the new container.
```sh
$ docker run -d \
 --restart=always \
 --net="host" \
 --volumes-from tvheadend-data \
 --name tvheadend-service \
 hobbsau/tvheadend
```  

You should see two new containers in the docker listing:
```sh
$ docker ps -a
```

## Developing
The [source repo](https://github.com/hobbsAU/docker-tvheadend) is linked to dockerhub using autobuild. Any push to this repo will auto-update the docker image on docker hub.
