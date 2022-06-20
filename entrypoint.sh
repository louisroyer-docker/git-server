#!/usr/bin/env bash
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

if [[ -n "${GROUP_ID}" ]]; then
	groupmod -g "${GROUP_ID}" git 1>&2 2> /dev/null || true # if same as default, there is no change
fi
if [[ -n "${USER_ID}" ]]; then
	usermod -u "${USER_ID}" git 1>&2 2>/dev/null || true # if same as default, there is no change
fi

# Update authorized keys
rm -f /etc/ssh/authorized_keys 1>&2 2>/dev/null || true # if already deleted, ignore
cat "${VOLUME_KEYS}"/*.pub > /etc/ssh/authorized_keys

# Fill template sshd_config
ETC_SSH="/etc/ssh"
SSHD_CONFIG="${ETC_SSH}/sshd_config"
cp /usr/local/share/sshd_config  "${SSHD_CONFIG}"
sed -i \
	-e "s%{{VOLUME_GIT}}%${VOLUME_GIT}%g" \
	-e "s%{{SSH_PORT}}%${SSH_PORT}%g" \
	"${SSHD_CONFIG}"

# Fill template no-interactive-login
HOME_GIT="/home/git"
GIT_SHELL_COMMANDS="${HOME_GIT}/git-shell-commands"
NOINTERACTIVELOGIN="${GIT_SHELL_COMMANDS}/no-interactive-login"
mkdir -p "${GIT_SHELL_COMMANDS}"
cp /usr/local/share/no-interactive-login.sh "${NOINTERACTIVELOGIN}"
sed -i \
	-e "s%{{VOLUME_GIT}}%${VOLUME_GIT}%g" \
	-e "s%{{OWNER}}%${OWNER}%g" \
	-e "s%{{FRONTEND_NAME}}%${FRONTEND_NAME}%g" \
	-e "s%{{FRONTEND_DOMAIN}}%${FRONTEND_DOMAIN}%g" \
	-e "s%{{FRONTEND_PORT}}%${FRONTEND_PORT}%g" \
	-e "s%{{INTRANET_NAME}}%${INTRANET_NAME}%g" \
	-e "s%{{INTRANET_DOMAIN}}%${INTRANET_DOMAIN}%g" \
	-e "s%{{INTRANET_PORT}}%${INTRANET_PORT}%g" \
	-e "s%{{TOR_NAME}}%${TOR_NAME}%g" \
	-e "s%{{TOR_DOMAIN}}%${TOR_DOMAIN}%g" \
	-e "s%{{TOR_PORT}}%${TOR_PORT}%g" \
	"${NOINTERACTIVELOGIN}" 

# Rights management
chown root:git -R "${HOME_GIT}" "${ETC_SSH}"
chmod -R g=rX,+st "${HOME_GIT}" "${ETC_SSH}"
chmod g+x "${NOINTERACTIVELOGIN}"

touch /run/sshd.pid
chown root:git /run/sshd.pid
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
	exec gosu git "/usr/bin/sshd" -D "${@:2}"
	;;
esac
