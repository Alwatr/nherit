FROM docker.io/library/nginx:1.31.6-alpine-otel AS build

# Alwatr native modules source
COPY modules/ /tmp/alwatr-modules/

# NGINX_VERSION is available from the base image
RUN --mount=type=cache,target=/var/cache/apk \
  set -eux; \
  printf "\n\x1b[0;36m🔸 Install dependencies\x1b[0m\n\n"; \
  apk add --no-cache \
    build-base \
    cmake \
    curl \
    git \
    linux-headers \
    openssl-dev \
    pcre-dev \
    zlib-dev; \
  \
  printf "\n\x1b[0;36m🔸 Download NGINX source code\x1b[0m\n\n"; \
  curl -sSL "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" | tar -xzC /tmp; \
  \
  printf "\n\x1b[0;36m🔸 Cloning headers-more-nginx-module repository\x1b[0m\n\n"; \
  git clone --depth=1 https://github.com/openresty/headers-more-nginx-module.git /tmp/headers-more-nginx-module; \
  \
  printf "\n\x1b[0;36m🔸 Cloning ngx_brotli repository\x1b[0m\n\n"; \
  git clone --depth=1 --recurse-submodules -j8 https://github.com/google/ngx_brotli.git /tmp/ngx_brotli; \
  \
  printf "\n\x1b[0;36m🔸 Build brotli\x1b[0m\n\n"; \
  cd /tmp/ngx_brotli/deps/brotli; \
  mkdir out; \
  cd out; \
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_C_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" \
    -DCMAKE_CXX_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" \
    -DCMAKE_INSTALL_PREFIX=./installed ..; \
  cmake \
    --build . \
    --config Release \
    --target brotlienc; \
  \
  printf "\n\x1b[0;36m🔸 Configure NGINX with the dynamic modules\x1b[0m\n\n"; \
  cd "/tmp/nginx-${NGINX_VERSION}"; \
  ./configure \
    --with-compat \
    --add-dynamic-module=/tmp/ngx_brotli \
    --add-dynamic-module=/tmp/headers-more-nginx-module \
    --add-dynamic-module=/tmp/alwatr-modules/ngx_http_lowercase_uri_module; \
  \
  printf "\n\x1b[0;36m🔸 Building the dynamic modules\x1b[0m\n\n"; \
  make modules; \
  \
  printf "\n\x1b[0;36m🔸 Copying the dynamic modules to /tmp/modules\x1b[0m\n\n"; \
  mkdir -p /tmp/modules; \
  cp -av \
    objs/ngx_http_brotli_filter_module.so \
    objs/ngx_http_brotli_static_module.so \
    objs/ngx_http_headers_more_filter_module.so \
    objs/ngx_http_lowercase_uri_module.so \
    /tmp/modules/;

# Final stage
FROM docker.io/library/nginx:1.31.6-alpine-otel

# Clean default configurations and files
RUN rm -rfv /docker-entrypoint* /etc/nginx/conf.d/* /etc/nginx/nginx.conf /var/www/html /usr/share/nginx/html /data

# Copy custom configuration files
COPY etc/nginx/ /etc/nginx/

# Copy the dynamic module from the build stage
COPY --from=build /tmp/modules/*.so /etc/nginx/modules/

# RUN ls -RlAhF /etc/nginx

EXPOSE 80
STOPSIGNAL SIGQUIT
WORKDIR /data
ENTRYPOINT ["/etc/nginx/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]

ARG BUILD_REV
ARG BUILD_DATE
LABEL org.opencontainers.image.title="alwatr/nginx" \
      org.opencontainers.image.description="The slim (lightweight) version of the NGINX web server, packaged by Alwatr." \
      org.opencontainers.image.base.name="docker.io/library/nginx:1.31.6-alpine-otel" \
      org.opencontainers.image.version="1.31.6" \
      org.opencontainers.image.ref.name="1.31.6-alpine-otel" \
      org.opencontainers.image.licenses="MPL-2.0" \
      org.opencontainers.image.created=${BUILD_DATE} \
      org.opencontainers.image.revision=${BUILD_REV} \
      org.opencontainers.image.vendor="Alwatr" \
      org.opencontainers.image.source="https://github.com/Alwatr/nginx" \
      org.opencontainers.image.url="https://github.com/Alwatr/nginx" \
      org.opencontainers.image.documentation="https://github.com/Alwatr/nginx" \
      org.opencontainers.image.authors="S. Ali Mihandoost <ali.mihandoost@gmail.com> (https://ali.mihandoost.com)"
