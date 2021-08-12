# Media center

- plex
- qbittorrent
- radarr: for automaticly having movies
- sonarr: for automaticly having tv shows
- Bazarr: is a companion application to Sonarr and Radarr. It can manage and download subtitles based on your requirements.
- jackett:  is a companion application to Sonarr and Radarr. Scraps torrents sites looking for the things that you want

```yaml
version: "3.9"

services:
  qbittorrent:
    image: ghcr.io/linuxserver/qbittorrent
    restart: always
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - WEBUI_PORT=8080
    volumes:
      - ${CONFIGS}/qbittorrent/:/config
      - ${DOWNLOADS}:/downloads
    ports:
      - 6881:6881
      - 6881:6881/udp
      - 8080:8080

  # Feeds with torrents to radarr and sonarr
  jackett:
    image: linuxserver/jackett
    container_name: jackett
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - UMASK_SET=022
      # - RUN_OPTS=run options here #optional
    volumes:
      - ${CONFIGS}/jackett/:/config
      - ${DOWNLOADS}/blackhole:/downloads
    ports:
      - 9117:9117


  # for automaticly having movies
  radarr:
    image: linuxserver/radarr:latest
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - UMASK_SET=022
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ${CONFIGS}/radarr:/config
      - ${DOWNLOADS}/completed/movies:/movies # movies folder
      - ${DOWNLOADS}:/downloads # download folder
    links:
      - qbittorrent
      - jackett
    ports:
      - 7878:7878

  # For automaticly having tv shows
  sonarr:
    image: linuxserver/sonarr
    container_name: sonarr
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - UMASK_SET=022
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ${CONFIGS}/sonarr:/config
      - ${DOWNLOADS}/completed/tv:/tv
      - ${DOWNLOADS}:/downloads
    ports:
      - 8989:8989
    links:
      - jackett
      - qbittorrent

  # Bazarr is a companion application to Sonarr and Radarr.
  # It can manage and download subtitles based on your requirements.
  # You define your preferences by TV show or movie and Bazarr takes care of everything for you.
  bazarr:
    image: linuxserver/bazarr
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - UMASK_SET=022
    volumes:
      - ${CONFIGS}/bazarr:/config
      - ${DOWNLOADS}/complete/movies:/movies
      - ${DOWNLOADS}/complete/tv:/tv
    ports:
      - 6767:6767
    links:
      - sonarr
      - radarr


  plex:
    image: ghcr.io/linuxserver/plex
    restart: always
    network_mode: host
    privileged: true
    environment:
      - VERSION=docker
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      # - PLEX_CLAIM=${PLEX_CLAIM}
    volumes:
      - ${CONFIGS}/plex:/config
      - ${CONFIGS}/plex/transcode:/transcode
      - ${DOWNLOADS}/complete/movies:/movies
      - ${DOWNLOADS}/complete/tv:/tv
```
