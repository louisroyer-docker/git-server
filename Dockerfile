FROM debian:bullseye-slim
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

# Templates
COPY ./sshd_config /usr/local/share/sshd_config
COPY ./no-interactive-login.sh /usr/local/share/no-interactive-login.sh

# Scripts
COPY --chmod="755" ./sshd_force_command.sh /usr/local/bin/sshd_force_command
COPY ./entrypoint.sh /usr/local/sbin/entrypoint.sh

WORKDIR /srv/git

ENV SSH_PORT=2222

ENV GROUP_ID=""
ENV USER_ID=""

ENV VOLUME_GIT=""
ENV VOLUME_KEYS=""

# Displayed owner of the git repository
ENV OWNER=""

# Displayed config values for Frontend
ENV FRONTEND_NAME=""
ENV FRONTEND_DOMAIN=""
ENV FRONTEND_PORT=""

# Displayed config values for Intranet
ENV INTRANET_NAME=""
ENV INTRANET_DOMAIN=""
ENV INTRANET_PORT=""

# Displayed config values for Tor
ENV TOR_NAME=""
ENV TOR_DOMAIN=""
ENV TOR_PORT=""

ENTRYPOINT ["entrypoint.sh"]
CMD ["--help"]
