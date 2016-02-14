# docker-tvheadend

Run tvheadend from a docker container

## Install
```sh
docker pull hobbsau/tvheadend
```

## Usage

```sh
$ docker create \
 --name tvheadend-data \
 -v <hostdir>:/config \
 -v <hostdir>:/recordings \
 hobbsau/tvheadend \
 /bin/true
```

Example using my host:
```sh
$ sudo docker create --name tvheadend-data -v /srv/tvheadend/config:/config -v /srv/tvheadend/recordings:/recordings hobbsau/tvheadend
```

$ docker run -d \
 --restart=always \
 --net="host" \
 --volumes-from tvheadend-data \
 --name tvheadend-service \
 hobbsau/tvheadend
```

## Developing
This repo is linked to dockerhub using autobuild. Any push to this repo will auto-update the docker image on docker hub.
