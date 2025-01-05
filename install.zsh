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


PACK_VERSION=0.11.1
PACK=Monifactory-Beta.$PACK_VERSION-server.zip

if [ ! -d $PACK.d ] ; then

  echo installing monifactory

  curl -sLO https://github.com/ThePansmith/Monifactory/releases/download/$PACK_VERSION/$PACK

  unzip -d $PACK.d $PACK 'overrides/*'

fi

cp -r $PACK.d/overrides/* ./

