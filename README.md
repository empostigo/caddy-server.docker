[Caddy](https://caddyserver.com/docs/) is a very handy server platform written in Golang which supports HTTPS by default.   
You can use this image as a reverse proxy to reach  an isolated docker container over HTTPS.   
When it starts, Caddy automatically configures HTTPS with a certificate obtained from let's encrypt for you domain name.

# New
## Raspberry PI
A version for Raspberry PI is now available. It has been produced on a Raspberry PI 4 with 4Gb RAM.
Use the aarch64 tag:
```
aexerces/caddy-server:aarch64
```

# Howto  
## Test it
The default command in the Dockerfile show version informations, so it's not very useful: 
```
docker run aexerces/caddy-server
```

Create a folder named caddy and place a Caddyfile in it: 
```
mkdir caddy
echo `your domain name` > caddy/Caddyfile
```    
We'll use this folder to mount it on /var/lib/caddy in the container to keep certificates and other caddy stuff.  
There are two environment variables used in the Dockerfile, which you can use to reflect the user id and the group id of your host. There are both set to 1000 by default.  
Use -e UID=your_uid -e  GID=your_gid to set them.  
To launch a fully fonctionnal container, issue this command:  
```
docker run -v $(pwd)/caddy:/var/lib/caddy -e UID=your_uid -e GID=your_gid -p 80:80 -p 443:443 aexerces/caddy-server caddy run  --config /var/lib/caddy/Caddyfile
```
You need to expose both 80 and 443 ports to reach the world :)  
If things get well, you'll see by the end of the output:  
```
Certificate obtained successfully
```
