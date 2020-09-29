#!/bin/sh

# configs
mkdir -p /etc/caddy/ /usr/share/caddy && wget $CADDYIndexPage -O /usr/share/caddy/index.html 
wget -qO- $CADDYCONFIG | sed -e "1c :$PORT" -e "s/\$SSPATH$/\\$SSPATH/" -e "s/\$GOSTPATH$/\\$GOSTPATH/" -e "s/\$BROOKPATH$/\\$BROOKPATH/" -e "s/\$VMESSPATH$/\\$VMESSPATH/" -e "s/\$VLESSPATH$/\\$VLESSPATH/" >/etc/caddy/Caddyfile
wget -qO- $V2RAYCONFIG | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$VMESSPATH$/\\$VMESSPATH/" -e "s/\$VLESSPATH$/\\$VLESSPATH/" >/v2ray.json

# start
[[ "$TOREnable"      ==    "true" ]]    &&    tor &

[[ "$V2RAYEnable"    ==    "true" ]]    &&    /v2ray -config /v2ray.json &

[[ "$BROOKEnable"    ==    "true" ]]    &&    brook wsserver -l 127.0.0.1:3234 --path $BROOKPATH -p $APASSWORD &

[[ "$GOSTEnable"     ==    "true" ]]    &&    gost ${GOSTMETHOD:="-L=ss+ws://AEAD_CHACHA20_POLY1305:$APASSWORD@127.0.0.1:2234?path=$GOSTPATH"} &

[[ "$SSEnable"       ==    "true" ]]    &&    ss-server -s 127.0.0.1 -p 1234 -k $APASSWORD -m $SSENCYPT --plugin /usr/bin/v2ray-plugin_linux_amd64 --plugin-opts "server;path=$SSPATH" &

caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
