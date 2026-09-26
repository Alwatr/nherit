/*
 * Alwatr lowercase URI module.
 *
 * Provides the $lowercase_redirect_uri variable:
 *   - empty when the request path (raw $request_uri before '?') has no ASCII uppercase letter;
 *   - otherwise the lowercased path followed by the untouched query string.
 *
 * Percent-encoded bytes are kept as-is (e.g. %D8%A7 does not trigger a redirect), except encoded
 * uppercase letters (%41-%5A), which are decoded to their lowercase form to avoid a redirect loop.
 * The variable is evaluated lazily with a single linear scan and allocates memory only on a redirect.
 */

#include <ngx_config.h>
#include <ngx_core.h>
#include <ngx_http.h>


static ngx_int_t ngx_http_lowercase_uri_add_variables(ngx_conf_t *cf);
static ngx_int_t ngx_http_lowercase_redirect_uri_variable(ngx_http_request_t *r,
    ngx_http_variable_value_t *v, uintptr_t data);
static ngx_int_t ngx_http_lowercase_uri_unhex(u_char *p);


static ngx_http_module_t  ngx_http_lowercase_uri_module_ctx = {
    ngx_http_lowercase_uri_add_variables,  /* preconfiguration */
    NULL,                                  /* postconfiguration */

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


static ngx_str_t  ngx_http_lowercase_redirect_uri_name =
    ngx_string("lowercase_redirect_uri");


static ngx_int_t
ngx_http_lowercase_uri_add_variables(ngx_conf_t *cf)
{
    ngx_http_variable_t  *var;

    var = ngx_http_add_variable(cf, &ngx_http_lowercase_redirect_uri_name, 0);
    if (var == NULL) {
        return NGX_ERROR;
    }

    var->get_handler = ngx_http_lowercase_redirect_uri_variable;

    return NGX_OK;
}


static ngx_int_t
ngx_http_lowercase_redirect_uri_variable(ngx_http_request_t *r,
    ngx_http_variable_value_t *v, uintptr_t data)
{
    u_char     *p, *last, *dst;
    ngx_int_t   ch;

    v->valid = 1;
    v->no_cacheable = 0;
    v->not_found = 0;

    p = r->unparsed_uri.data;
    last = p + r->unparsed_uri.len;

    /* fast path: scan the path for an uppercase letter, no allocation */

    for ( /* void */ ; p < last; p++) {

        if (*p == '?') {
            break;
        }

        if (*p >= 'A' && *p <= 'Z') {
            goto found;
        }

        if (*p == '%' && last - p >= 3) {
            ch = ngx_http_lowercase_uri_unhex(p + 1);

            if (ch >= 'A' && ch <= 'Z') {
                goto found;
            }

            p += 2;
        }
    }

    v->len = 0;
    v->data = (u_char *) "";

    return NGX_OK;

found:

    /* the result is never longer than the original */

    v->data = ngx_pnalloc(r->pool, r->unparsed_uri.len);
    if (v->data == NULL) {
        return NGX_ERROR;
    }

    dst = ngx_cpymem(v->data, r->unparsed_uri.data, p - r->unparsed_uri.data);

    for ( /* void */ ; p < last; p++) {

        if (*p == '?') {
            dst = ngx_cpymem(dst, p, last - p);
            break;
        }

        if (*p >= 'A' && *p <= 'Z') {
            *dst++ = *p | 0x20;
            continue;
        }

        if (*p == '%' && last - p >= 3) {
            ch = ngx_http_lowercase_uri_unhex(p + 1);

            if (ch >= 'A' && ch <= 'Z') {
                *dst++ = (u_char) (ch | 0x20);

            } else {
                dst = ngx_cpymem(dst, p, 3);
            }

            p += 2;
            continue;
        }

        *dst++ = *p;
    }

    v->len = dst - v->data;

    return NGX_OK;
}


static ngx_int_t
ngx_http_lowercase_uri_unhex(u_char *p)
{
    u_char      c;
    ngx_int_t   n;
    ngx_uint_t  i;

    n = 0;

    for (i = 0; i < 2; i++) {
        c = p[i];

        if (c >= '0' && c <= '9') {
            n = n * 16 + (c - '0');
            continue;
        }

        c |= 0x20;

        if (c >= 'a' && c <= 'f') {
            n = n * 16 + (c - 'a' + 10);
            continue;
        }

        return -1;
    }

    return n;
}
