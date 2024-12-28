#!/usr/bin/env zsh

token="$(stoml secrets.toml token)"
key="$(stoml --multi secrets.toml key)"
remote_key="$(stoml --multi secrets.toml remote_key)"
sticky_name="antimatter"
zone_id="$(stoml config.toml zone_id)"
name=antimatter-$(tr -dc a-z </dev/urandom | head -c 8)

# create dark server

false && {
  hcloud server create --image ubuntu-24.04 --name $name --ssh-key antimatter --type ccx13
  describe="$(hcloud server describe $name -o json)"
  echo $describe > describe.json
} || {
  describe="$(cat describe.json)" # tagout
}
ipv4_dns_ptr="$(echo $describe | jq -r .public_net.ipv4.dns_ptr)"

ssh-add /dev/stdin <<< $key

count=0
while ! ssh root@$ipv4_dns_ptr -- echo hello world from $ipv4_dns_ptr ; do
  echo failed to contact new server
  if [ $count -lt 1 ] ; then
    count=$((count+1))
    echo retrying in five seconds
    sleep 5
  else ; break ; fi
done

ssh root@$ipv4_dns_ptr -- 'cat > $HOME/.ssh/id_ed25519 && chmod 600 $HOME/.ssh/id_ed25519' <<< $remote_key
ssh root@$ipv4_dns_ptr -- 'apt-get update && apt-get upgrade && apt-get install -y openjdk-17-jre-headless screen unzip zsh'
ssh root@$ipv4_dns_ptr -- 'ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts && rm -rf antimatter ; git clone git@github.com:bingecraft-net/antimatter.git'
ssh root@$ipv4_dns_ptr -- 'rm -rf server && ./antimatter/install.zsh'
ssh root@$ipv4_dns_ptr -- 'screen -d -m -S minecraft ./antimatter/start.zsh'

# update sticky dns

payload="$(
curl -s "https://dns.hetzner.com/api/v1/records?zone_id=$zone_id" \
  -H "Auth-API-Token: $token"
)"

record="$(echo $payload | jq '.records[] | select(.name == "antimatter")')"

update="$(jq -n --arg value "$ipv4_dns_ptr" --arg name "$sticky_name" --arg zone_id "$zone_id" '{value:$value,ttl:300,type:"CNAME",name:$name,zone_id:$zone_id}')"

if [ "$record" = "" ]; then
  curl -s -X "POST" "https://dns.hetzner.com/api/v1/records" \
    -H 'Content-Type: application/json' \
    -H "Auth-API-Token: $token" \
    -d "$update"
else
  id="$(echo $record | jq -r .id)"
  curl -s -X "PUT" "https://dns.hetzner.com/api/v1/records/$id" \
    -H 'Content-Type: application/json' \
    -H "Auth-API-Token: $token" \
    -d "$update"
fi


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
