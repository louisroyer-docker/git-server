#!/usr/bin/env bash
set -e

OWNER="{{OWNER}}"

FRONTEND_NAME="{{FRONTEND_NAME}}"
FRONTEND_DOMAIN="{{FRONTEND_DOMAIN}}"
FRONTEND_PORT="{{FRONTEND_PORT}}"

INTRANET_NAME="{{INTRANET_NAME}}"
INTRANET_DOMAIN="{{INTRANET_DOMAIN}}"
INTRANET_PORT="{{INTRANET_PORT}}"

TOR_NAME="{{TOR_NAME}}"
TOR_DOMAIN="{{TOR_DOMAIN}}"
TOR_PORT="{{TOR_PORT}}"

if [[ -n "${OWNER}" ]]; then
	printf '%s\n\n' "${OWNER}'s private Git Server"
else
	printf '%s\n\n' "Private Git Server"
fi

printf '%s\n' "SSH Configuration:"

if [[ -n "${FRONTEND_NAME}" ]]; then
	printf '%s\n' "Host ${FRONTEND_DOMAIN}"
	printf '\t%s\n' "User git"
	if [[ -n "${FRONTEND_DOMAIN}" ]]; then
		printf '\t%s\n' "Hostname ${FRONTEND_DOMAIN}"
	fi
	if [[ -n "${FRONTEND_PORT}" ]]; then
		printf '\t%s\n' "Port ${FRONTEND_PORT}"
	fi
	printf '\t%s\n\n' "IdentityFile ~/.ssh/id_rsa"
fi

if [[ -n "${INTRANET_NAME}" ]]; then
	printf '%s\n' "Host ${INTRANET_DOMAIN}"
	printf '\t%s\n' "User git"
	if [[ -n "${INTRANET_DOMAIN}" ]]; then
		printf '\t%s\n' "Hostname ${INTRANET_DOMAIN}"
	fi
	if [[ -n "${INTRANET_PORT}" ]]; then
		printf '\t%s\n' "Port ${INTRANET_PORT}"
	fi
	printf '\t%s\n\n' "IdentityFile ~/.ssh/id_rsa"
fi

if [[ -n "${TOR_NAME}" ]]; then
	printf '%s\n' "Host ${TOR_DOMAIN}"
	printf '\t%s\n' "User git"
	if [[ -n "${TOR_DOMAIN}" ]]; then
		printf '\t%s\n' "Hostname ${TOR_DOMAIN}"
	fi
	if [[ -n "${TOR_PORT}" ]]; then
		printf '\t%s\n' "Port ${TOR_PORT}"
	fi
	printf '\t%s\n\n' "IdentityFile ~/.ssh/id_rsa"
	printf '\t%s\n\n' "ProxyCommand bash -c 'SOCKS5_PASSWORD=\"\" connect-proxy -S 127.0.0.1:9050 %h %p'"
fi

printf '%s\n' "Repositories list:"
find /srv/git -maxdepth 3 -type d -name '*.git' -printf '- %P\n'
