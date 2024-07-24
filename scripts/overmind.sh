#!/bin/sh

# Create Procfile in the current directory or a specific directory
cat > /Procfile <<EOF
tailscaled: /scripts/tailscaled.sh
supercronic: /scripts/supercronic.sh
adguardhome: /scripts/adguardhome.sh
EOF

# Start Overmind using the created Procfile
overmind start -f /Procfile