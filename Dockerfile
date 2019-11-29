FROM debian:10.1 as build 
MAINTAINER Rob Gil <rob@rem5.com>
# Originally written by Chaim Sanders. See https://github.com/CRS-support/modsecurity-docker/blob/v2/ubuntu-nginx/Dockerfile
# Modified for use by Tassat and upgraded to latest versions

# Install Prereqs
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -qq && \
    apt-get install -qq -y --no-install-recommends --no-install-suggests \
      apache2-dev         \
      automake            \
      ca-certificates     \
      libssl-dev          \
      libcurl4-gnutls-dev \
      libpcre++-dev       \
      libtool             \
      libxml2-dev         \
      libyajl-dev         \
      lua5.2-dev          \
      pkgconf             \
      ssdeep              \
      zlib1g-dev          \
      wget             && \
    apt-get clean && rm -rf /var/lib/apt/lists/* 

# Download ModSecurity
RUN cd /opt && \
    wget  --quiet https://github.com/SpiderLabs/ModSecurity/releases/download/v2.9.3/modsecurity-2.9.3.tar.gz && \
    wget  --quiet https://nginx.org/download/nginx-1.17.6.tar.gz && \
    tar -xzf modsecurity-2.9.3.tar.gz && \
    tar -xzf nginx-1.17.6.tar.gz

# Install ModSecurity
RUN cd /opt/modsecurity-2.9.3/ && \
    sh autogen.sh && \
    ./configure --enable-standalone-module && make

RUN cd /opt/nginx-1.17.6 && \
    ./configure --add-module=/opt/modsecurity-2.9.3/nginx/modsecurity --prefix=/usr/local/nginx --with-http_ssl_module && \
    make && make install && make clean

# Move Files
RUN cd /opt/modsecurity-2.9.3/ && \
    mkdir -p /usr/local/nginx/conf/modsecurity.d && \
    mv modsecurity.conf-recommended  /usr/local/nginx/conf/modsecurity.d/modsecurity.conf && \
    mv unicode.mapping /usr/local/nginx/conf/modsecurity.d/ && \
    printf "include modsecurity.conf" > /usr/local/nginx/conf/modsecurity.d/includes.conf && \
    sed -i -e 's/^ *location \/.*/\tlocation \/ {\n\t    ModSecurityEnabled on;\n\t    ModSecurityConfig modsecurity.d\/includes.conf;/g' /usr/local/nginx/conf/nginx.conf

####################

FROM debian:10.1

COPY --from=build /usr/local/nginx /usr/local/nginx

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -qq && \
    apt-get install -qq -y --no-install-recommends --no-install-suggests \
      libapr1         \
      libaprutil1     \
      libc6           \
      libcurl3-gnutls \
      liblua5.2-0     \
      libxml2         \
      zlib1g          \
      libyajl2    &&  \
    apt-get clean && rm -rf /var/lib/apt/lists/* 

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]

