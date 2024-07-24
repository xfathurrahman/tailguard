#!/bin/sh

# Function to ensure directory exists
ensure_directory() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
    fi
}

# Ensure directories if they don't exist
ensure_directory /data/conf
ensure_directory /data/work
ensure_directory /var/run/tailscale
ensure_directory /var/cache/tailscale
ensure_directory /var/lib/tailscale

# Remove and recreate symlinks
rm -rf /opt/adguardhome/conf /opt/adguardhome/work
ln -s /data/conf /opt/adguardhome/conf
ln -s /data/work /opt/adguardhome/work

# Set symlink for sendmail
ln -sf /usr/bin/msmtp /usr/bin/sendmail
ln -sf /usr/bin/msmtp /usr/sbin/sendmail

# Set permissions
chmod +x /usr/local/bin/supercronic
chmod +x /usr/local/bin/overmind
chmod +x /usr/local/bin/tailscaled
chmod +x /usr/local/bin/tailscale
chmod +x /scripts/*.sh

# Run Overmind
/scripts/overmind.sh