FROM debian:latest
MAINTAINER Adrian Hobbs <adrianhobbs@gmail.com>
ENV DEBIAN_FRONTEND noninteractive
ENV TVH_BRANCH master

# Update packages in base image, avoid caching issues by combining statements, install build software and deps
RUN apt-get update && apt-get install -y \
build-essential \
git \ 
pkg-config \
libssl-dev \
bzip2 \
wget \
libavahi-client-dev \ 
zlib1g-dev \
libavcodec-dev \
libavutil-dev \
libavformat-dev \
libswscale-dev \
python \
gettext \
&& rm -rf /var/lib/apt/lists/*


# Build tvheadend
RUN git clone https://github.com/tvheadend/tvheadend.git /opt/tvheadend
WORKDIR /opt/tvheadend 
RUN git checkout $TVH_BRANCH
RUN ./configure --enable-hdhomerun_static --enable-libffmpeg_static 
RUN make && make install
WORKDIR /opt

# Clean up packages, build-essentials and src 
RUN rm -r /opt/tvheadend && apt-get purge -qq \
build-essential \
git \
pkg-config \
libssl-dev \
bzip2 \
wget \
libavahi-client-dev \
zlib1g-dev \
libavcodec-dev \
libavutil-dev \
libavformat-dev \
libswscale-dev \
python \
gettext \
&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 9981 9982

# Add a user to run as non root
RUN adduser --disabled-password --gecos '' hts

ENTRYPOINT ["/usr/local/bin/tvheadend"]
CMD ["-C","-u","hts","-g","hts","-c","/config"]

