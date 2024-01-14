#!/bin/ash

# Acces port 80 and 443 as non-root user
setcap 'cap_net_bind_service=+ep' /usr/bin/caddy

# create caddy group and user with UID and GID
adduser  -g "$GID" \
	 -u "$UID" \
	 -D \
	 -h /var/lib/caddy \
	 -H \
	 -s /sbin/nologin \
	 caddy

chown -R "$UID":"$GID" /var/lib/caddy
chown -R "$UID":"$GID" /var/www/dev
chown -R "$UID":"$GID" /var/log/caddy
exec gosu caddy tini -- "$@"

