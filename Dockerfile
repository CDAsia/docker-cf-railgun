FROM debian:stretch
MAINTAINER John Chlark Sumatra <jcsumatra@cdasia.com>

ENV RG_WAN_PORT=2408 \
	RG_LOG_LEVEL=0 \
	RG_ACT_TOKEN="" \
	RG_ACT_HOST="" \
	RG_NAT="" \
	RG_MEMCACHED_SERVERS="memcached:11211"

## Install Railgun
ENV RG_VERSION=5.3.3
RUN apt-get update -qq \
  && apt-get install -y \
  	curl \
  	gnupg \
  && echo 'deb http://pkg.cloudflare.com/ stretch main' | tee /etc/apt/sources.list.d/cloudflare-main.list \
  && curl -C - https://pkg.cloudflare.com/pubkey.gpg | apt-key add - \
  && apt-get update \
  && apt-get install -y railgun-stable=${RG_VERSION}

## Install dockerize
ENV DOCKERIZE_VERSION v0.6.1
RUN curl -fsSLO --compressed "https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz" \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN apt-get purge curl -y \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY ./railgun-nat.tmpl /etc/railgun/
COPY ./railgun.tmpl /etc/railgun/

EXPOSE 2408

COPY ./docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/bin/rg-listener -config=/etc/railgun/railgun.conf"]