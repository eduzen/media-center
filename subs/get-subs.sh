#!/usr/bin/env bash

if [ -f .env ]; then
  export $(echo $(cat .env | sed 's/#.*//g'| xargs) | envsubst)
fi

while true; do
  subliminal download -l en es nl /media/* /download/*
  sleep 360
done
