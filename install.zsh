#!/usr/bin/env zsh

mkdir -p server
cd server

if [ ! -f run.sh ] ; then

  INSTALLER_VERSION=1.20.1-47.3.22
  INSTALLER=forge-$INSTALLER_VERSION-installer.jar

  echo installing forge

  curl -sLO https://maven.minecraftforge.net/net/minecraftforge/forge/$INSTALLER_VERSION/$INSTALLER

  java -jar $INSTALLER --installServer > /dev/null

fi
