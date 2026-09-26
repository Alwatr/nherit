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

### Lowercase URI Redirect (SEO)

If all your files are lowercase, set `NGINX_LOWERCASE_URI=on` to permanently redirect any request whose path contains uppercase letters to its lowercase version (the query string is preserved), instead of returning 404.

```Dockerfile
ENV NGINX_LOWERCASE_URI=on \
    NGINX_LOWERCASE_URI_STATUS=301
```

When disabled (default), the related config and the njs module are removed at startup, so there is no runtime overhead. When enabled, lowercase requests only pay for a single JIT-compiled regex check; the njs handler runs only for the redirected requests.

## Sponsors

The following companies, organizations, and individuals support Nginx ongoing maintenance and development. Become a Sponsor to get your logo on our README and website.

### Contributing

Contributions are welcome! Please read our [contribution guidelines](https://github.com/Alwatr/.github/blob/next/CONTRIBUTING.md) before submitting a pull request.

### License

This project is licensed under the [MPL-2.0 License](LICENSE).
