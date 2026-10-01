/*
 * Alwatr lowercase URI module.
 *
 * Adds the $lowercase_uri variable: the current normalized request URI ($uri) in lowercase.
 * It is meant as a try_files fallback, so it is evaluated only when the original file is missing:
 *
 *     try_files $uri $uri/ $lowercase_uri $lowercase_uri/ =404;
 */

#include <ngx_config.h>
#include <ngx_core.h>
#include <ngx_http.h>


static ngx_int_t ngx_http_lowercase_uri_variable(ngx_http_request_t *r,
    ngx_http_variable_value_t *v, uintptr_t data);
static ngx_int_t ngx_http_lowercase_uri_add_variable(ngx_conf_t *cf);


static ngx_http_module_t  ngx_http_lowercase_uri_module_ctx = {
    ngx_http_lowercase_uri_add_variable,   /* preconfiguration */
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


static ngx_str_t  ngx_http_lowercase_uri_name = ngx_string("lowercase_uri");


static ngx_int_t
ngx_http_lowercase_uri_variable(ngx_http_request_t *r,
    ngx_http_variable_value_t *v, uintptr_t data)
{
    v->data = ngx_pnalloc(r->pool, r->uri.len);
    if (v->data == NULL) {
        return NGX_ERROR;
    }

    ngx_strlow(v->data, r->uri.data, r->uri.len);

    v->len = r->uri.len;
    v->valid = 1;
    v->no_cacheable = 0;
    v->not_found = 0;

    return NGX_OK;
}


static ngx_int_t
ngx_http_lowercase_uri_add_variable(ngx_conf_t *cf)
{
    ngx_http_variable_t  *var;

    /* not cacheable, like $uri: it follows $uri after internal redirects */

    var = ngx_http_add_variable(cf, &ngx_http_lowercase_uri_name, NGX_HTTP_VAR_NOCACHEABLE);
    if (var == NULL) {
        return NGX_ERROR;
    }

    var->get_handler = ngx_http_lowercase_uri_variable;

    return NGX_OK;
}
