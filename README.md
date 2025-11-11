# systemd-ssh-socks5-proxy
Small bash script to setup on-demand ssh socks5 proxy to a host

```
# bash script that setup an on-demand SSH proxy
# Three unit files will be created to serve this purpose:
#   ssh-${DISPLAYED_HOSTNAME}-socks-proxy.socket - The listening socket providing activation
#   ssh-${DISPLAYED_HOSTNAME}-socks-proxy.servic - A systemd proxy to pass the socket fde
#   ssh-${DISPLAYED_HOSTNAME}-socks-tunnel.service - The actual SSH service providing the tunnel
```

## How-to use it ?

simply export the corresponding ENVs :

`export DISPLAYED_HOSTNAME=host SSH_HOSTNAME=host.example.com TUNNEL_PORT=10080 LOCAL_PORT=1080`

And start setup.sh, it will try to connect to the host over ssh and setup the systemd units accordingly
