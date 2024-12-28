#!/usr/bin/env zsh

echo hello world from $0

: '
todo
- create dark server
    - new ubuntu hetzner cloud server
    - upsert dark A record for new server
    - install dependencies from code
    - install minecraft server from code
- try to freeze and replicate from live server
    - notify active players that a checkpoint is being made and moved to an upgraded server. all progress after this message will not be moved to the new server
    - create backup on live server
    - unpack latest backup to git world
    - prune unclaimed chunks from git world
    - commit and push world
- start dark server
    - pull world
    - start minecraft server
- swap dark and live dns
    - temp = configured live
    - configured live = configured dark
    - configured dark = temp
- try to teardown dark server
    - notify dark players that the server has been upgraded successfully. please reconnect
    - delete server
'
