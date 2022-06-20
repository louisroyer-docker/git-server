#!/usr/bin/env bash
set -e
umask 0077
SSH_ORIGINAL_COMMAND=$1
VOLUME_GIT=$2
read -ra arr <<< "${SSH_ORIGINAL_COMMAND}"
if [ -z "$SSH_ORIGINAL_COMMAND" ]; then
	git-shell
elif [ ${#arr[@]} -eq 2 ] && [[ "${arr[0]}" == "git-upload-pack" || "${arr[0]}" == "git-receive-pack" || "${arr[0]}" == "git-upload-archive" ]]; then
	if [[ "${arr[1]}" =~ .*".git'" ]]; then
		arr[1]="${arr[1]:0:1}${VOLUME_GIT}/${arr[1]:1:-1}${arr[1]:${#arr[1]}-1}"
	else
		arr[1]="${arr[1]:0:1}${VOLUME_GIT}/${arr[1]:1:-1}.git${arr[1]:${#arr[1]}-1}"
	fi
	if [ "${arr[0]}" == "git-upload-pack" ]; then
		# check repo exists
		if [ "$(find "$(dirname "${arr[1]:1:-1}")" -type d -iname "$(basename "${arr[1]:1:-1}")" 2> /dev/null| wc -l)" -eq 0 ]; then
			if [[ $(dirname "${arr[1]:1:-1}") =~ .*".git/".* ]]; then
				echo "remote: error: Forbidden path." > /dev/stderr
				exit 1
			fi
			# push to create
			echo "remote: This repository does not exists yet. Initialization…" > /dev/stderr
			mkdir -p "$(dirname "${arr[1]:1:-1}")"
			git -C "$(dirname "${arr[1]:1:-1}")" init --quiet --bare "$(basename "${arr[1]:1:-1}")"
			echo "done." > /dev/stderr
		fi
	fi
	git-shell -c "${arr[*]}"
else
	git-shell -c "${SSH_ORIGINAL_COMMAND}"
fi


