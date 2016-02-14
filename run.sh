#!/bin/bash
sudo docker rm tvheadend-service
sudo docker rm tvheadend-data

sudo docker pull hobbsau/tvheadend

sudo docker create \
 --name tvheadend-data \
 -v /srv/tvheadend/config:/config \
 -v /srv/tvheadend/recordings:/recordings \
 hobbsau/tvheadend

sleep 2

sudo docker run -d \
 --restart=always \
 --net="host" \
 --volumes-from tvheadend-data \
 --name tvheadend-service \
 hobbsau/tvheadend

