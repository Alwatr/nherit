// Lowercase the path of $request_uri and keep the query string untouched.
// Percent-encoded bytes are kept as-is, except encoded uppercase letters (%41-%5A) that would cause a redirect loop.
function redirectUri(r) {
  const requestUri = r.variables.request_uri;
  const queryIndex = requestUri.indexOf('?');
  const path = queryIndex === -1 ? requestUri : requestUri.slice(0, queryIndex);
  const query = queryIndex === -1 ? '' : requestUri.slice(queryIndex);

  return (
    path.replace(/%([0-9A-Fa-f]{2})|[A-Z]+/g, (match, hex) => {
      if (hex === undefined) return match.toLowerCase();
      const code = parseInt(hex, 16);
      return code >= 0x41 && code <= 0x5a ? String.fromCharCode(code + 32) : match;
    }) + query
  );
}

export default {redirectUri};
