# Media center

- samba
- plex
- qbittorrent
- radarr: for automaticly having movies
- sonarr: for automaticly having tv shows
- Bazarr: is a companion application to Sonarr and Radarr. It can manage and download subtitles based on your requirements.
- jackett:  is a companion application to Sonarr and Radarr. Scraps torrents sites looking for the things that you want
- traktv: for tracking what you watch

## How to use?

Easy: first copy `.env.sample` to `.env` and fill it with your data. And then run `docker-compose up -d`

- plex [http://localhost:9117/](http://localhost:9117/)
- qbittorrent [http://localhost:8080/](http://localhost:8080/)
- radarr: [http://localhost:6767/](http://localhost:6767/)
- sonarr: [http://localhost:8989/](http://localhost:8989/)
- Bazarr: [http://localhost:6767/](http://localhost:6767/)
- jackett: [http://localhost:9117/](http://localhost:9117/)

```yaml
version: "3.9"

x-common-env: &common-env
  restart: always
  environment:
    - PUID=${PUID}
    - PGID=${PGID}
    - TZ=${TZ}
    - UMASK_SET=${UNMASK_SET}
    - WEBUI_PORT={QBITTORRENT_WEBUI_PORT}
    - VERSION=docker

services:

  samba:
    image: dperson/samba:rpi
    restart: always
    command: '-u "${USER};{PASS}" -s "downloads;/downloads;yes;no"'
    stdin_open: true
    tty: true
    <<: *common-env
    volumes:
      - ${DOWNLOADS}:/downloads
    ports:
      - 139:130
      - 445:445

  plex:
    image: ghcr.io/linuxserver/plex:version-1.24.0.4930-ab6e1a058
    privileged: true
    network: host
    <<: *common-env
    volumes:
      - ./traktv-plugin:${PLEXPLUGINS}/Trakttv.bundle
      - ${CONFIGS}/plex:/config
      - ${CONFIGS}/plex/db:${PLEXDB}
      - ${CONFIGS}/plex/plugins:${PLEXPLUGINS}
      - ${CONFIGS}/plex/transcode:/transcode
      - ${MOVIES}:/movies
      - ${TV}:/tv
      - ${MUSIC}:/music

  qbittorrent:
    image: ghcr.io/linuxserver/qbittorrent:unstable-version-4.4.0202106140855-7320-2bd5aca3aubuntu20.04.1
    <<: *common-env
    ports:
      - 6881:6881
      - 6881:6881/udp
      - 8080:8080
    volumes:
      - ${CONFIGS}/qbittorrent/:/config
      - ${DOWNLOADS}:/downloads

  # Feeds with torrents to radarr and sonarr
  jackett:
    image: linuxserver/jackett
    <<: *common-env
    volumes:
      - ${CONFIGS}/jackett:/config
      - ${DOWNLOADS}/blackhole:/downloads
    ports:
      - 9117:9117

  # for automaticly having movies
  radarr:
    image: linuxserver/radarr:version-3.2.2.5080
    <<: *common-env
    volumes:
      - ${CONFIGS}/radarr:/config
      - ${MOVIES}:/movies
      - ${DOWNLOADS}:/downloads
    links:
      - qbittorrent
      - jackett
    ports:
      - 7878:7878

  # For automaticly having tv shows
  # Another option is Medusa
  sonarr:
    image: linuxserver/sonarr:develop-version-3.0.6.1305
    container_name: sonarr
    <<: *common-env
    volumes:
      - ${CONFIGS}/sonarr:/config
      - ${DOWNLOADS}:/downloads
      - ${TV}:/tv
      ports:
      - 8989:8989
    links:
      - jackett
      - qbittorrent

  # Bazarr is a companion application to Sonarr and Radarr.
  # It can manage and download subtitles based on your requirements.
  # You define your preferences by TV show or movie and Bazarr takes care of everything for you.
  bazarr:
    image: linuxserver/bazarr:development-version-v0.9.7
    <<: *common-env
    volumes:
      - ${CONFIGS}/bazarr:/config
      - ${MOVIES}:/movies
      - ${TV}:/tv
    ports:
      - 6767:6767
    links:
      - sonarr
      - radarr
```
