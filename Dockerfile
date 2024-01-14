ARG GOLANG_VERSION=1.22rc1-alpine3.19
ARG ALPINE_VERSION=3.19.0

FROM golang:${GOLANG_VERSION} AS builder

LABEL maintainer="Emmanuel Postigo <empostigo@gmx.fr>"


RUN apk --no-cache add git \
		       build-base \
		       gcc

WORKDIR /go/src/app

RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
RUN xcaddy build --with github.com/caddy-dns/cloudflare@latest

FROM alpine:${ALPINE_VERSION}

# install caddy
COPY --from=builder /go/src/app/caddy /usr/bin/caddy

# validate install
RUN /usr/bin/caddy version
RUN /usr/bin/caddy environ
RUN caddy list-modules

# From gosu, https://github.com/tianon/gosu/blob/master/INSTALL.md
ARG GOSU_VERSION=1.17
RUN set -eux; \
  \
  apk add --no-cache --virtual .gosu-deps \
    ca-certificates \
    dpkg \
    gnupg \
    ; \
  \
  dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
  wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
  wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
  \
  # verify the signature
  export GNUPGHOME="$(mktemp -d)"; \
  gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
  gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
  command -v gpgconf && gpgconf --kill all || :; \
  rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
  \
  # clean up fetch dependencies
  apk del --no-network .gosu-deps; \
  \
  chmod +x /usr/local/bin/gosu; \
  # verify that the binary works
  gosu --version; \
  gosu nobody true

RUN apk --no-cache add \
        libcap \
        tini

EXPOSE 80 443 2015

WORKDIR /var/lib/caddy

ENV UID="1000"
ENV GID="1000"

VOLUME /var/lib/caddy
VOLUME /var/www/dev
VOLUME /var/log/caddy

COPY docker-entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["caddy","version"]
