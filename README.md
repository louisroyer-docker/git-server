# Getting started
![Docker Image CI](https://github.com/louisroyer-docker/git-server/actions/workflows/docker-image.yml/badge.svg)
![CI](https://github.com/louisroyer-docker/git-serveractions/workflows/main.yml/badge.svg)
```yaml
version: "3.8"

services:
  git-server:
    container_name: git-server
    hostname: git-server
    restart: always
    image: louisroyer/git-server
    volumes:
      - /srv/git:/srv/git # this volume contains git repositories
      - /srv/git-keys:/srv/git-keys:ro # add public keys in this volume, restart is required after each change
    secrets:
      - keys-host-rsa
      - keys-host-rsa.pub
      - keys-host-ed25519
      - keys-host-ed25519.pub
    environment:
      SSH_PORT: "2222" # port of the container listenned on
      GROUP_ID: "1000" # edit to match your Group ID
      USER_ID: "1000" # edit to match your UID
      VOLUME_GIT: "/srv/git"
      VOLUME_KEYS: "/srv/git-keys"
      OWNER: "John Smith"
      FRONTEND_NAME: "example.org"
      FRONTEND_DOMAIN: "git.example.org"
      FRONTEND_PORT: "2222"
      INTRANET_NAME: "example.local"
      INTRANET_DOMAIN: "git.example.local"
      INTRANET_PORT: "22"
      TOR_NAME: "git.example.onion"
      TOR_DOMAIN: "v3qi0dpzp5n3bhb0oczxph722hhnvie8psvuvx5du8svnq7emw9qd0gg.onion"
      TOR_PORT: "22"
    command: ["--start", "-e"]
    ports:
      - "127.0.0.1:8082:2222"
    networks:
      git-net:
    logging:
      driver: journald
      options:
        tag: "{{.ImageName}}/{{.ID}}"

networks:
  git-net:
    name: git-net
    ipam:
      driver: default
      config:
        - subnet: "172.20.0.0/30"
          gateway: "172.20.0.1"
          
# keys must be already generated, restart is required after each change          
secrets:
  keys-host-rsa:
    file: /etc/ssh/ssh_host_rsa_key
  keys-host-ed25519:
    file: /etc/ssh/ssh_host_ed25519_key
  keys-host-rsa.pub:
    file: /etc/ssh/ssh_host_rsa_key.pub
  keys-host-ed25519.pub:
    file: /etc/ssh/ssh_host_ed25519_key.pub
```
