#!/bin/sh

tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
sleep 5
tailscale up --ssh --authkey=${TAILSCALE_AUTHKEY} --hostname=${TAILSCALE_HOSTNAME}
tailscale cert ${TAILSCALE_HOSTNAME}.${TAILSCALE_DNS}

exec /scripts/adguardhome.sh