#!/bin/sh
# Substitute the appliance's host ports into the console page at start.
# The nginx image runs everything in /docker-entrypoint.d before starting.

set -eu

: "${PHILTER_PORT:=8444}"
: "${POLICY_EDITOR_PORT:=8445}"
: "${ARBITER_PORT:=8446}"
: "${PHILTERSCOPE_PORT:=8447}"

export PHILTER_PORT POLICY_EDITOR_PORT ARBITER_PORT PHILTERSCOPE_PORT

# Explicit list, so other $ in the page's CSS and JavaScript is left alone.
envsubst '${PHILTER_PORT} ${POLICY_EDITOR_PORT} ${ARBITER_PORT} ${PHILTERSCOPE_PORT}' \
	< /usr/share/nginx/html/index.html.template \
	> /usr/share/nginx/html/index.html

echo "console: rendered index.html"
