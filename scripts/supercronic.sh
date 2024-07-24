#!/bin/sh

# Run cron job every 8 hours
cat > /crontab <<EOF
0 */8 * * * /scripts/restic.sh
EOF

supercronic /crontab