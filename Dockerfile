# Copyright 2024 Louis Royer. All rights reserved.
# Use of this source code is governed by a MIT-style license that can be
# found in the LICENSE file.
# SPDX-License-Identifier: MIT

FROM debian:bookworm-slim
LABEL maintainer="Louis Royer <infos.louis.royer@gmail.com>" \
      org.opencontainers.image.authors="Louis Royer <infos.louis.royer@gmail.com>" \
      org.opencontainers.image.source="https://github.com/louisroyer/docker-git-server"

ARG DEFAULT_GROUP_ID=1001
ARG DEFAULT_USER_ID=1001

# Used to disable caching of next steps, if not build since 1 day,
# allowing to search and apply security upgrades
ARG BUILD_DATE=""

RUN apt-get update -q && \
    DEBIAN_FRONTEND=non-interactive apt-get upgrade -qy && \
    DEBIAN_FRONTEND=non-interactive apt-get install -qy openssh-server git gosu --no-install-recommends --no-install-suggests && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/sbin/sshd /usr/bin/sshd && \
    rm -f /etc/ssh/ssh_host_*_key* && \
    mkdir -p /home/git && \
    adduser git --gecos "" --no-create-home --quiet --disabled-password && \
    groupmod -g "${DEFAULT_GROUP_ID}" git && \
    usermod -u "${DEFAULT_USER_ID}" git && \
    mkdir -p /etc/ssh/keys-host && \
    ln -s /run/secrets/keys-host-rsa /etc/ssh/keys-host/ssh_host_rsa_key && \
    ln -s /run/secrets/keys-host-rsa.pub /etc/ssh/keys-host/ssh_host_rsa_key.pub && \
    ln -s /run/secrets/keys-host-ed25519 /etc/ssh/keys-host/ssh_host_ed25519_key && \
    ln -s /run/secrets/keys-host-ed25519.pub /etc/ssh/keys-host/ssh_host_ed25519_key.pub

COPY ./sshd_config ./no-interactive-login.sh /usr/local/share/
COPY --chmod="755" ./sshd_force_command.sh /usr/local/bin/
COPY ./entrypoint.sh /usr/local/sbin/

WORKDIR /srv/git

ENV SSH_PORT=2222 \
    GROUP_ID="" \
    USER_ID="" \
    VOLUME_GIT="" \
    VOLUME_KEYS="" \
    OWNER="" \
    FRONTEND_NAME="" \
    FRONTEND_DOMAIN="" \
    FRONTEND_PORT="" \
    INTRANET_NAME="" \
    INTRANET_DOMAIN="" \
    INTRANET_PORT="" \
    TOR_NAME="" \
    TOR_DOMAIN="" \
    TOR_PORT=""

ENTRYPOINT ["entrypoint.sh"]
CMD ["--help"]
