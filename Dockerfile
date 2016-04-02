FROM alpine:edge
MAINTAINER Adrian Hobbs <adrianhobbs@gmail.com>
ENV PACKAGE "tvheadend-git tvheadend-git-dvb-scan libhdhomerun tzdata"

# Update packages in base image, avoid caching issues by combining statements, install build software and deps
RUN	echo "http://dl-6.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
	apk add --no-cache $PACKAGE && \
	mkdir -p /config /recordings && \
	chown -R tvheadend:nogroup /config /recordings && \
	cp /usr/share/zoneinfo/Australia/Sydney /etc/localtime && \
	echo "Australia/Sydney" > /etc/timezone

EXPOSE 9981 9982

#ENTRYPOINT ["/usr/bin/tvheadend"]
CMD ["/usr/bin/tvheadend","-C","-u","tvheadend","-g","tvheadend","-c","/config"]

