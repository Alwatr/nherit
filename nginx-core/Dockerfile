FROM ghcr.io/alwatr/nginx:4.12.0

RUN apk add --no-cache curl libwebp-tools brotli
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --start-interval=1s --retries=3 CMD curl -fso /dev/null http://localhost/server-info || exit 1

WORKDIR /data

COPY etc/nginx/ /etc/nginx/
COPY default-data/ /default-data/
COPY tools/ /usr/local/bin/
# RUN ls -RlahF /etc/nginx /default-data /data /usr/local/bin

# Default environment for nginx template
ENV NGINX_WORKER_CONNECTIONS=2048 \
    NGINX_ACCESS_LOG="off" \
    NGINX_ENABLE_ACCESS_LOG="on" \
    NGINX_ERROR_LOG_LEVEL=notice \
    NGINX_WORKER_CONNECTIONS=2048 \
    NGINX_LIMIT_REQ_ERROR=503 \
    NGINX_LIMIT_REQ_LOG=notice \
    NGINX_AUTOINDEX=off \
    NGINX_DOCUMENT_ROOT=/data \
    NGINX_FORCE_DOMAIN="" \
    NGINX_FORCE_DOMAIN_STATUS=302 \
    NGINX_FORCE_REDIRECT_STATUS=307 \
    NGINX_AUTO_WEBP="off" \
    NGINX_LOWERCASE_URI="off" \
    NGINX_PROCESSES_AUTOTUNE="off" \
    NGINX_WORKER_PROCESSES=1 \
    NGINX_CORS_ENABLE="off" \
    NGINX_CORS_ORIGIN="*" \
    NGINX_CORS_METHODS="GET, OPTIONS" \
    NGINX_CORS_HEADERS="*" \
    NGINX_CORS_MAXAGE=86400 \
    NGINX_DISALLOW_ROBOTS="off" \
    NGINX_RESOLVERS="local" \
    NGINX_RESOLVER_VALID=10s

ENV NGINX_CLIENT_MAX_BODY_SIZE=10m \
    NGINX_SENDFILE=on \
    NGINX_SENDFILE_MAX_CHUNK=2m \
    NGINX_TCP_NOPUSH=on \
    NGINX_TCP_NODELAY=on \
    NGINX_OPEN_FILE_CACHE="max=1000 inactive=30m" \
    NGINX_OPEN_FILE_CACHE_VALID=1s \
    NGINX_OPEN_FILE_CACHE_MIN_USES=2 \
    NGINX_OUTPUT_BUFFERS="8 16k" \
    NGINX_EXPIRES_DYNAMIC=epoch \
    NGINX_EXPIRES_STATIC=epoch \
    NGINX_EXPIRES_DEFAULT=epoch \
    NGINX_LIMIT_REQ_RATE=200 \
    NGINX_LIMIT_REQ_BURST=1000 \
    NGINX_GZIP=on \
    NGINX_GZIP_STATIC=off \
    NGINX_GZIP_VARY=on \
    NGINX_GZIP_COMP_LEVEL=5 \
    NGINX_GZIP_MIN_LENGTH=500 \
    NGINX_BROTLI=on \
    NGINX_BROTLI_STATIC=off \
    NGINX_BROTLI_COMP_LEVEL=6 \
    NGINX_BROTLI_MIN_LENGTH=50 \
    NGINX_DISABLE_SYMLINKS=if_not_owner \
    NGINX_PERMISSIONS_POLICY="geolocation=(), microphone=(), camera=()"

ARG BUILD_REV
ARG BUILD_DATE
LABEL org.opencontainers.image.title="alwatr/nginx-core" \
      org.opencontainers.image.description="This is a high-performance version of NGINX, which has been enhanced by Alwatr for the purpose of serving static content efficiently." \
      org.opencontainers.image.base.name="ghcr.io/alwatr/nginx:4.12.0" \
      org.opencontainers.image.version="4.12.0-nginx1.29.1" \
      org.opencontainers.image.ref.name="4.12.0-nginx1.29.1-alpine-otel" \
      org.opencontainers.image.licenses="MPL-2.0" \
      org.opencontainers.image.created=${BUILD_DATE} \
      org.opencontainers.image.revision=${BUILD_REV} \
      org.opencontainers.image.vendor="Alwatr" \
      org.opencontainers.image.source="https://github.com/Alwatr/nginx" \
      org.opencontainers.image.url="https://github.com/Alwatr/nginx" \
      org.opencontainers.image.documentation="https://github.com/Alwatr/nginx" \
      org.opencontainers.image.authors="S. Ali Mihandoost <ali.mihandoost@gmail.com> (https://ali.mihandoost.com)"
