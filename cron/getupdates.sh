#!/bin/bash

# change to the zroc directory
cd /home/zroc/zroc

# pull any updates from the git repository
git pull

# check if there are any changes
if [[ $(git diff HEAD@{1} HEAD) ]]; then
  # if there are changes, run docker-compose up with force-restart
  docker-compose up -d --force-restart
fi
