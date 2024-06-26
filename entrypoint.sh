#!/usr/bin/env bash
# Copyright 2024 Louis Royer. All rights reserved.
# Use of this source code is governed by a MIT-style license that can be
# found in the LICENSE file.
# SPDX-License-Identifier: MIT

set -e
# Check env variables are set
if [[ -z "${VOLUME_GIT}" ]]; then
	echo "VOLUME_GIT environment variable is not set."
	exit 1
fi

if [[ -z "${VOLUME_KEYS}" ]]; then
	echo "VOLUME_KEYS environment variable is not set."
	exit 1
fi

# Allow sshd to be run as a non root user
ln -sf /usr/sbin/sshd /usr/bin/sshd

# Symlink secrets into /etc/ssh/keys-host
mkdir -p /etc/ssh/keys-host
ln -sf /run/secrets/keys-host-rsa /etc/ssh/keys-host/ssh_host_rsa_key
ln -sf /run/secrets/keys-host-rsa.pub /etc/ssh/keys-host/ssh_host_rsa_key.pub
ln -sf /run/secrets/keys-host-ed25519 /etc/ssh/keys-host/ssh_host_ed25519_key
ln -sf /run/secrets/keys-host-ed25519.pub /etc/ssh/keys-host/ssh_host_ed25519_key.pub

# Create user
HOME_GIT="/home/${USER:-git}"
mkdir -p "${HOME_GIT}"
adduser "${USER:-git}" --gecos "" --no-create-home --quiet --disabled-password || true # if already created, ignore
groupmod -g "${GROUP_ID:-1001}" "${USER:-git}" || true # if already in group, ignore
usermod -u "${USER_ID:-1001}" "${USER:-git}" || true # if already this userid, ignore


# Update authorized keys
rm -f /etc/ssh/authorized_keys 1>&2 2>/dev/null || true # if already deleted, ignore
cat "${VOLUME_KEYS}"/*.pub > /etc/ssh/authorized_keys

# Fill template sshd_config
ETC_SSH="/etc/ssh"
SSHD_CONFIG="${ETC_SSH}/sshd_config"
awk \
	-v VOLUME_GIT="${VOLUME_GIT}" \
	-v SSH_PORT="${SSH_PORT}" \
	'{
		sub(/{{VOLUME_GIT}}/, VOLUME_GIT);
		sub(/{{SSH_PORT}}/, SSH_PORT);
		print;
	}' \
	/usr/local/share/sshd_config > "${SSHD_CONFIG}"

# Fill template no-interactive-login
GIT_SHELL_COMMANDS="${HOME_GIT}/git-shell-commands"
NOINTERACTIVELOGIN="${GIT_SHELL_COMMANDS}/no-interactive-login"
mkdir -p "${GIT_SHELL_COMMANDS}"
awk \
	-v VOLUME_GIT="${VOLUME_GIT}" \
	-v USER="${USER:-git}" \
	-v OWNER="${OWNER}" \
	-v FRONTEND_NAME="${FRONTEND_NAME}" \
	-v FRONTEND_DOMAIN="${FRONTEND_DOMAIN}" \
	-v FRONTEND_VERIFY_HOST_KEY_DNS="${FRONTEND_VERIFY_HOST_KEY_DNS}" \
	-v FRONTEND_PORT="${FRONTEND_PORT}" \
	-v INTRANET_NAME="${INTRANET_NAME}" \
	-v INTRANET_DOMAIN="${INTRANET_DOMAIN}" \
	-v INTRANET_PORT="${INTRANET_PORT}" \
	-v TOR_NAME="${TOR_NAME}" \
	-v TOR_DOMAIN="${TOR_DOMAIN}" \
	-v TOR_PORT="${TOR_PORT}" \
	' {
		sub(/{{VOLUME_GIT}}/, VOLUME_GIT);
		sub(/{{OWNER}}/, OWNER);
		sub(/{{USER}}/, USER);
		sub(/{{FRONTEND_NAME}}/, FRONTEND_NAME);
		sub(/{{FRONTEND_DOMAIN}}/, FRONTEND_DOMAIN);
		sub(/{{FRONTEND_VERIFY_HOST_KEY_DNS}}/, FRONTEND_VERIFY_HOST_KEY_DNS);
		sub(/{{FRONTEND_PORT}}/, FRONTEND_PORT);
		sub(/{{INTRANET_NAME}}/, INTRANET_NAME);
		sub(/{{INTRANET_DOMAIN}}/, INTRANET_DOMAIN);
		sub(/{{INTRANET_PORT}}/, INTRANET_PORT);
		sub(/{{TOR_NAME}}/, TOR_NAME);
		sub(/{{TOR_DOMAIN}}/, TOR_DOMAIN);
		sub(/{{TOR_PORT}}/, TOR_PORT);
		print;
	}' \
	/usr/local/share/no-interactive-login.sh > "${NOINTERACTIVELOGIN}"

# Rights management
chown "root:${USER:-git}" -R "${HOME_GIT}" "${ETC_SSH}"
chmod -R g=rX,+st "${HOME_GIT}" "${ETC_SSH}"
chmod g+x "${NOINTERACTIVELOGIN}"

touch /run/sshd.pid
chown "root:${USER:-git}" /run/sshd.pid
chmod g+w,+s /run/sshd.pid

# exec sshd process using git user
case "$1" in
-h|--help)
	printf '%s\n' "Git server help:"
	printf '\t%s\n' "--start: start the server (use it only as first argument)."
	printf '\t%s\n' "--help or -h: display this help message and exit (only when used as first argument)."
	printf '\t%s\n' "See SSHD(8) for other possible arguments. -D option of sshd is forced."
	;;
--start)
	cd "${VOLUME_GIT}"
	exec gosu "${USER:-git}" "/usr/bin/sshd" -D "${@:2}"
	;;
esac
