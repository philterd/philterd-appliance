# The appliance console: a launcher over the other products.
# Static page plus same-origin health probes, served by nginx.

FROM nginx:1.29-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY probe.conf /etc/nginx/appliance/probe.conf

# Rendered to index.html at container start.
COPY site/index.html /usr/share/nginx/html/index.html.template

COPY docker-entrypoint.d/40-render-console.sh /docker-entrypoint.d/40-render-console.sh
RUN chmod +x /docker-entrypoint.d/40-render-console.sh \
	&& rm -f /usr/share/nginx/html/index.html

EXPOSE 80
