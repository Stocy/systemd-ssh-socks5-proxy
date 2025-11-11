#!/bin/bash
# These steps will allow the setup of an on-demand SSH proxy
# Three unit files will be created to serve this purpose:
#   ssh-${DISPLAYED_HOSTNAME}-socks-proxy.socket - The listening socket providing activation
#   ssh-${DISPLAYED_HOSTNAME}-socks-proxy.servic - A systemd proxy to pass the socket fde
#   ssh-${DISPLAYED_HOSTNAME}-socks-tunnel.service - The actual SSH service providing the tunnel

if test -z "$DISPLAYED_HOSTNAME" || test -z "$SSH_HOSTNAME" || test -z "$TUNNEL_PORT" || test -z "$LOCAL_PORT" ; then
        echo Envs DISPLAYED_HOSTNAME SSH_HOSTNAME TUNNEL_PORT LOCAL_PORT should be defined !
        echo Example: export DISPLAYED_HOSTNAME=host SSH_HOSTNAME=host.example.com TUNNEL_PORT=10080 LOCAL_PORT=1080
        exit
fi

export TUNNEL_COMMAND="/usr/bin/ssh -aqND ${TUNNEL_PORT} ${SSH_HOSTNAME} sleep 3600"
export TUNNEL_TEST="/usr/bin/ssh ${SSH_HOSTNAME} exit"

cat <<'%' | envsubst
echo setting up on-demand ssh proxy for ${DISPLAYED_HOSTNAME}
testing ssh connection: $TUNNEL_TEST
%

${TUNNEL_TEST} && echo OK

export proxy_sock_name="ssh-${DISPLAYED_HOSTNAME}-socks-proxy.socket"
export proxy_svc_name="ssh-${DISPLAYED_HOSTNAME}-socks-proxy.service"
export tunnel_svc_name="ssh-${DISPLAYED_HOSTNAME}-socks-tunnel.service"

systemctl --user unmask ${tunnel_svc_name}
systemctl --user unmask ${proxy_sock_name}
systemctl --user unmask ${proxy_svc_name}
systemctl --user daemon-reload


file="${HOME}/.config/systemd/user/${proxy_sock_name}"
echo storing into $file ====
cat <<'EOF' | envsubst | tee $file
[Unit]
Description=Proxify ssh tunnel of ${DISPLAYED_HOSTNAME} locally on port ${LOCAL_PORT}
[Socket]
ListenStream=${LOCAL_PORT}
[Install]
WantedBy=sockets.target
EOF
echo ""

file="${HOME}/.config/systemd/user/${proxy_svc_name}"
echo storing into $file ====
cat <<'EOF' | envsubst | tee $file
[Unit]
Description=Proxify ssh tunnel of ${DISPLAYED_HOSTNAME} locally on port ${LOCAL_PORT}
Requires=${proxy_sock_name}
BindsTo=${tunnel_svc_name}
After=${tunnel_svc_name}
[Service]
ExecStartPre=/bin/sleep 5
ExecStart=/lib/systemd/systemd-socket-proxyd 127.0.0.1:${TUNNEL_PORT}
TimeoutStopSec=5
[Install]
WantedBy=multi-user.target
EOF
echo ""

file="${HOME}/.config/systemd/user/${tunnel_svc_name}"
echo storing into $file ====
cat <<'EOF' | envsubst | tee $file
[Unit]
Description=On-Demand ssh SOCKS5 tunnel with ${SSH_HOSTNAME}
[Service]
ExecStart=${TUNNEL_COMMAND}
[Install]
WantedBy=multi-user.target
EOF
echo ""

systemctl --user daemon-reload
systemctl --user enable ${tunnel_svc_name}
systemctl --user enable ${proxy_sock_name}
systemctl --user enable ${proxy_svc_name}
systemctl --user start ${proxy_sock_name}
systemctl --user status ${proxy_sock_name}
