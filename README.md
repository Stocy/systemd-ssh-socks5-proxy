# systemd-ssh-socks5-proxy
Small bash script to setup on-demand ssh socks5 proxy to a host

## How-to use it ?

simply export the corresponding ENVs :

`export DISPLAYED_HOSTNAME=host SSH_HOSTNAME=host.example.com TUNNEL_PORT=10080 LOCAL_PORT=1080`

And start setup.sh, it will try to connect to the host over ssh and setup the systemd units accordingly
