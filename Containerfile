FROM ubuntu:noble

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl openjdk-21-jdk unzip zsh

RUN curl -sLO https://github.com/itzg/rcon-cli/releases/download/1.6.9/rcon-cli_1.6.9_linux_amd64.tar.gz && \
    tar xf rcon-cli_1.6.9_linux_amd64.tar.gz rcon-cli && \
    mv rcon-cli /bin/rcon-cli && \
    rm rcon-cli_1.6.9_linux_amd64.tar.gz

COPY ./bin/ /bin/
COPY ./overrides/ /overrides/

RUN useradd -m minecraft
RUN chown -R minecraft:minecraft /home/minecraft

USER minecraft
WORKDIR /home/minecraft

RUN mkdir backups server
WORKDIR server

RUN export INSTALLER_VERSION=1.20.1-47.3.7 && \
    export INSTALLER=forge-$INSTALLER_VERSION-installer.jar && \
    curl -svLO https://maven.minecraftforge.net/net/minecraftforge/forge/$INSTALLER_VERSION/$INSTALLER && \
    java -jar $INSTALLER --installServer

RUN export PACK_VERSION=0.11.5 && \
    export PACK=Monifactory-Beta.$PACK_VERSION-server.zip && \
    curl -sLO https://github.com/ThePansmith/Monifactory/releases/download/$PACK_VERSION/$PACK && \
    unzip -d $PACK.d $PACK 'overrides/*' && \
    cp -r $PACK.d/overrides/* ./

CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
