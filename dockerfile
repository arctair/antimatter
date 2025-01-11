FROM ubuntu:noble

RUN apt-get update && \
    apt-get upgrade && \
    apt-get install -y curl openjdk-21-jdk zsh

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

RUN curl -sLO https://api.papermc.io/v2/projects/paper/versions/1.21.4/builds/84/downloads/paper-1.21.4-84.jar

CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
