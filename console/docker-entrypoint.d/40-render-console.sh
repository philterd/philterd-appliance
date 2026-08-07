#!/bin/sh
#
# Render the console page from its template at container start.
#
# The nginx image runs every executable in /docker-entrypoint.d before starting
# nginx. This substitutes the appliance's host ports into the page so the tiles
# link to whatever ports this deployment was configured with, rather than
# hardcoding them into the HTML.

set -eu

: "${PHILTER_PORT:=8444}"
: "${POLICY_EDITOR_PORT:=8445}"
: "${ARBITER_PORT:=8446}"

export PHILTER_PORT POLICY_EDITOR_PORT ARBITER_PORT

# The variable list is explicit so that envsubst leaves any other $ in the
# page's CSS or JavaScript untouched.
envsubst '${PHILTER_PORT} ${POLICY_EDITOR_PORT} ${ARBITER_PORT}' \
	< /usr/share/nginx/html/index.html.template \
	> /usr/share/nginx/html/index.html

echo "console: rendered index.html (philter=$PHILTER_PORT policy-editor=$POLICY_EDITOR_PORT arbiter=$ARBITER_PORT)"
