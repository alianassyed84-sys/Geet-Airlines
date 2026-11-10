export async function onRequest(context) {
  const url = new URL(context.request.url);

  // If a live backend is configured in Cloudflare environment variables, proxy to it
  if (context.env.BACKEND_ORIGIN) {
    const targetUrl = context.env.BACKEND_ORIGIN + url.pathname + url.search;
    const reqHeaders = new Headers(context.request.headers);
    reqHeaders.set("X-Forwarded-Host", url.host);
    reqHeaders.set("X-Forwarded-Proto", url.protocol.replace(":", ""));

    const init = {
      method: context.request.method,
      headers: reqHeaders,
      redirect: "manual"
    };

    if (context.request.method !== "GET" && context.request.method !== "HEAD") {
      init.body = context.request.body;
    }

    try {
      const resp = await fetch(targetUrl, init);
      if (resp.status !== 404 && resp.status !== 502 && resp.status !== 503) {
        return resp;
      }
    } catch (e) {
      // Backend unavailable; fall through to static pages
    }
  }

  // Handle JSP page routes by mapping to static HTML equivalents
  if (url.pathname.endsWith(".jsp") || url.pathname === "/home" || url.pathname === "/") {
    let cleanPath = url.pathname;
    if (cleanPath === "/" || cleanPath === "/home.jsp" || cleanPath === "/home") {
      cleanPath = "/index.html";
    } else {
      cleanPath = cleanPath.replace(/\.jsp$/, ".html");
    }
    // Redirect to the HTML equivalent
    return Response.redirect(new URL(cleanPath + url.search, url.origin), 302);
  }

  // Serve static assets from the public directory
  return context.next();
}
