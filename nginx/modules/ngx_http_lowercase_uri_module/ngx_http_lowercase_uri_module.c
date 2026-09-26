/*
 * Alwatr lowercase URI module.
 *
 * Lowercases the normalized request URI ($uri) once, before any rewrite or location matching,
 * so every location and try_files serves the lowercase file without a redirect.
 * $request_uri and the query string stay untouched. Loading the module enables it.
 */

#include <ngx_config.h>
#include <ngx_core.h>
#include <ngx_http.h>


static ngx_int_t ngx_http_lowercase_uri_handler(ngx_http_request_t *r);
static ngx_int_t ngx_http_lowercase_uri_init(ngx_conf_t *cf);


static ngx_http_module_t  ngx_http_lowercase_uri_module_ctx = {
    NULL,                                  /* preconfiguration */
    ngx_http_lowercase_uri_init,           /* postconfiguration */

    NULL,                                  /* create main configuration */
    NULL,                                  /* init main configuration */

    NULL,                                  /* create server configuration */
    NULL,                                  /* merge server configuration */

    NULL,                                  /* create location configuration */
    NULL                                   /* merge location configuration */
};


ngx_module_t  ngx_http_lowercase_uri_module = {
    NGX_MODULE_V1,
    &ngx_http_lowercase_uri_module_ctx,    /* module context */
    NULL,                                  /* module directives */
    NGX_HTTP_MODULE,                       /* module type */
    NULL,                                  /* init master */
    NULL,                                  /* init module */
    NULL,                                  /* init process */
    NULL,                                  /* init thread */
    NULL,                                  /* exit thread */
    NULL,                                  /* exit process */
    NULL,                                  /* exit master */
    NGX_MODULE_V1_PADDING
};


static ngx_int_t
ngx_http_lowercase_uri_handler(ngx_http_request_t *r)
{
    u_char  *p, *last, *uri;

    last = r->uri.data + r->uri.len;

    /* find the first byte that changes when lowercased */

    for (p = r->uri.data; p < last; p++) {
        if (ngx_tolower(*p) != *p) {
            break;
        }
    }

    if (p == last) {
        return NGX_DECLINED;
    }

    uri = r->uri.data;

    if (uri == r->unparsed_uri.data) {
        /* $uri shares the client buffer with $request_uri, keep the latter untouched */

        uri = ngx_pnalloc(r->pool, r->uri.len);
        if (uri == NULL) {
            return NGX_HTTP_INTERNAL_SERVER_ERROR;
        }

        ngx_memcpy(uri, r->uri.data, p - r->uri.data);
    }

    ngx_strlow(uri + (p - r->uri.data), p, last - p);

    r->uri.data = uri;
    ngx_http_set_exten(r);

    return NGX_DECLINED;
}


static ngx_int_t
ngx_http_lowercase_uri_init(ngx_conf_t *cf)
{
    ngx_http_handler_pt        *h;
    ngx_http_core_main_conf_t  *cmcf;

    cmcf = ngx_http_conf_get_module_main_conf(cf, ngx_http_core_module);

    h = ngx_array_push(&cmcf->phases[NGX_HTTP_POST_READ_PHASE].handlers);
    if (h == NULL) {
        return NGX_ERROR;
    }

    *h = ngx_http_lowercase_uri_handler;

    return NGX_OK;
}
