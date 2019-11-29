# Modsecurity / NGINX Docker Image
This container is a 100% source build of NGINX and Modsecurity. The intent of this image is to be used as a WAF with complex configurations which are not possible with cloud provider provided WAF services. Modsecurity's rules can be configured in very advanced ways to do deep inspection on content and request/response bodies.  

## Starting the container
Basic startup commands. You'll likely want to specify custom configurations here and ensure it runs unprivileged. 
```
docker create --name waf robgil/modsecurity-nginx:2.9.3
docker start waf
```

## Paths

_nginx:_ `/usr/local/nginx/conf`
_modsecuriity:_: `/usr/local/nginx/conf/modsecurity.d`

# Dockerhub
I periodically build images for personal use. The images are on [dockerhub](https://hub.docker.com/repository/docker/robgil/modsecurity-nginx).

# Credits
Originally written by Chaim Sanders and using the Apache 2.0 license. See https://github.com/CRS-support/modsecurity-docker/blob/v2/ubuntu-nginx/Dockerfile. This has been modified for use with debian 10.1.


