FROM alpine:edge
MAINTAINER Adrian Hobbs <adrianhobbs@gmail.com>
ENV PACKAGE "tvheadend tvheadend-dvb-scan libhdhomerun"

# Update packages in base image, avoid caching issues by combining statements, install build software and deps
RUN	echo "http://dl-6.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
	apk add --no-cache $PACKAGE 
	# Add a user to run as non root
	#adduser -D -g '' hts

EXPOSE 9981 9982

ENTRYPOINT ["/usr/bin/tvheadend"]
CMD ["-C","-u","tvheadend","-g","tvheadend","-c","/config"]

