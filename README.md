# Alwatr Accelerated Web Server

This is a high-performance version of NGINX, which has been enhanced by Alwatr for the purpose of serving static content efficiently.

## Usage

The recommended method for using the Alwatr Nginx is to place it behind a Kubernetes ingress or a simple edge reverse-proxy like Traefik.  
In this setup, there's no need to configure edge features such as SSL, Domain, etc. in the Alwatr Nginx.

```Dockerfile
FROM ghcr.io/alwatr/nginx:2
```

### Serve Progressive Web Apps

```Dockerfile
ARG NODE_VERSION=lts
ARG ALWATR_NGINX_VERSION=2
FROM docker.io/library/node:${NODE_VERSION} as builder
WORKDIR /app
COPY package.json *.lock ./
RUN if [ -f *.lock ]; then \
      yarn install --frozen-lockfile --non-interactive --production false; \
    else \
      yarn install --non-interactive --production false; \
    fi;
COPY . .
RUN yarn build

# ---

FROM ghcr.io/alwatr/nginx-pwa:${ALWATR_NGINX_VERSION} as nginx
# Config nginx
ENV NGINX_ACCESS_LOG="/var/log/nginx/access.log json"
# Copy builded files from last stage
COPY --from=builder /app/dist/ ./
RUN pwd; ls -lAhF;
```

### Lowercase URI (SEO)

If all your files are lowercase, set `NGINX_LOWERCASE_URI=on` to serve any request path with uppercase letters from its lowercase file (e.g. `/Assets/Logo.PNG` serves `/assets/logo.png`) instead of returning 404. There is no redirect; `$request_uri` and the query string stay untouched.

```Dockerfile
ENV NGINX_LOWERCASE_URI=on
```

This is done by a tiny native module (`ngx_http_lowercase_uri_module`, built in the base `nginx` image) that lowercases `$uri` once, before any rewrite or location matching. When disabled (default), the module is not loaded at all, so there is no runtime overhead. When enabled, each request pays only for a single byte scan of its path; memory is allocated only when the path has an uppercase letter.

### Regular Expression Performance (PCRE JIT)

PCRE Just-In-Time compilation is enabled by default (`pcre_jit on;`) in the main configuration context. Regular expressions defined at configuration parsing time (such as `location ~ ...`, `rewrite`, and `map` directives used for MIME-type mapping and WebP detection) are JIT-compiled into native machine code at startup, significantly reducing CPU overhead and speeding up regex matching during request handling.

## Sponsors

The following companies, organizations, and individuals support Nginx ongoing maintenance and development. Become a Sponsor to get your logo on our README and website.

### Contributing

Contributions are welcome! Please read our [contribution guidelines](https://github.com/Alwatr/.github/blob/next/CONTRIBUTING.md) before submitting a pull request.

### License

This project is licensed under the [MPL-2.0 License](LICENSE).
