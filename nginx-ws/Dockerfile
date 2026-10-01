FROM ghcr.io/alwatr/nginx-core:4.16.1

COPY etc/nginx/ /etc/nginx/
# COPY default-data/ /default-data/
# RUN ls -RlahF /etc/nginx /default-data /data

# Default environment for nginx template
ENV NGINX_CLIENT_MAX_BODY_SIZE=1k \
    NGINX_SENDFILE=on \
    NGINX_SENDFILE_MAX_CHUNK=2m \
    NGINX_TCP_NOPUSH=on \
    NGINX_TCP_NODELAY=on \
    NGINX_OPEN_FILE_CACHE="max=1000 inactive=1h" \
    NGINX_OPEN_FILE_CACHE_VALID=1M \
    NGINX_OPEN_FILE_CACHE_MIN_USES=2 \
    NGINX_OUTPUT_BUFFERS="8 16k" \
    NGINX_EXPIRES_DYNAMIC=epoch \
    NGINX_EXPIRES_STATIC=max \
    NGINX_EXPIRES_DEFAULT=epoch \
    NGINX_LIMIT_REQ_RATE=400 \
    NGINX_LIMIT_REQ_BURST=1000 \
    NGINX_GZIP=on \
    NGINX_GZIP_VARY=on \
    NGINX_GZIP_COMP_LEVEL=5 \
    NGINX_GZIP_MIN_LENGTH=256 \
    NGINX_DISABLE_SYMLINKS=if_not_owner

ARG BUILD_REV
ARG BUILD_DATE
ARG BUILD_VERSION=dev
ENV IMAGE_VERSION=$BUILD_VERSION \
    IMAGE_REVISION=$BUILD_REV
LABEL org.opencontainers.image.title="alwatr/nginx-ws" \
      org.opencontainers.image.description="This is a high-performance version of NGINX, which has been enhanced by Alwatr for the purpose of serving static website content efficiently." \
      org.opencontainers.image.base.name="ghcr.io/alwatr/nginx-core:4.16.1" \
      org.opencontainers.image.version="4.16.1" \
      org.opencontainers.image.ref.name="4.16.1-nginx1.31.6-alpine-otel" \
      org.opencontainers.image.licenses="MPL-2.0" \
      org.opencontainers.image.created=${BUILD_DATE} \
      org.opencontainers.image.revision=${BUILD_REV} \
      org.opencontainers.image.vendor="Alwatr" \
      org.opencontainers.image.source="https://github.com/Alwatr/nginx" \
      org.opencontainers.image.url="https://github.com/Alwatr/nginx" \
      org.opencontainers.image.documentation="https://github.com/Alwatr/nginx" \
      org.opencontainers.image.authors="S. Ali Mihandoost <ali.mihandoost@gmail.com> (https://ali.mihandoost.com)"
