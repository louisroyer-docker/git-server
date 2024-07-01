# Copyright 2024 Louis Royer. All rights reserved.
# Use of this source code is governed by a MIT-style license that can be
# found in the LICENSE file.
# SPDX-License-Identifier: MIT

FROM debian:bookworm-slim
LABEL maintainer="Louis Royer <infos.louis.royer@gmail.com>" \
      org.opencontainers.image.authors="Louis Royer <infos.louis.royer@gmail.com>" \
      org.opencontainers.image.source="https://github.com/louisroyer/docker-git-server"

# Used to disable caching of next steps, if not build since 1 day,
# allowing to search and apply security upgrades
ARG BUILD_DATE=""

RUN apt-get update -q && \
    DEBIAN_FRONTEND=non-interactive apt-get upgrade -qy && \
    DEBIAN_FRONTEND=non-interactive apt-get install -qy openssh-server git gosu --no-install-recommends --no-install-suggests && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/ssh/ssh_host_*_key*

COPY ./sshd_config ./no-interactive-login.sh /usr/local/share/
COPY --chmod="755" ./sshd_force_command.sh /usr/local/bin/
COPY ./entrypoint.sh /usr/local/sbin/

WORKDIR /srv/git

ENV SSH_PORT=2222 \
    GROUP_ID="" \
    USER_ID="" \
    USER="" \
    VOLUME_GIT="" \
    VOLUME_KEYS="" \
    OWNER="" \
    FRONTEND_NAME="" \
    FRONTEND_DOMAIN="" \
    FRONTEND_PORT="" \
    FRONTEND_VERIFY_HOST_KEY_DNS="" \
    INTRANET_NAME="" \
    INTRANET_DOMAIN="" \
    INTRANET_PORT="" \
    TOR_NAME="" \
    TOR_DOMAIN="" \
    TOR_PORT=""

ENTRYPOINT ["entrypoint.sh"]
CMD ["--help"]
