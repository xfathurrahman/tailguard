#!/bin/sh

set -o pipefail

EMAIL_SUBJECT_PREFIX="[Restic]"
LOG="/var/log/restic/$(date +%Y%m%d_%H%M%S).log"
DATE_TIME=$(date +"%Y-%m-%d %H:%M:%S")

mkdir -p /var/log/restic/

cat << EOF > /etc/msmtprc
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        /var/log/msmtp.log

account        default
host           ${SMTP_HOST}
port           ${SMTP_PORT}
from           ${SMTP_FROM}
user           ${SMTP_USERNAME}
password       ${SMTP_PASSWORD}
EOF

chmod 600 /etc/msmtprc

# Function to send HTML email notifications
function notify() {
    local subject="$1"
    local message="$2"
    local log_file="$3"

    # Construct HTML email body
    local email_body=$(cat <<EOF
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; }
        h1 { color: #F44336; }
        pre { background-color: #f4f4f4; padding: 10px; border-radius: 5px; }
        .footer { margin-top: 20px; font-size: 0.9em; color: #777; }
    </style>
</head>
<body>
    <h1>${subject}</h1>
    <p><strong>Date:</strong> ${DATE_TIME}</p>
    <p><strong>Status:</strong> ${message}</p>
    <pre>${message}</pre>
    <p class="footer">For more details, check the attached log file: ${log_file}</p>
</body>
</html>
EOF
)

    echo "${email_body}" | mail -a "Content-Type: text/html" -s "${EMAIL_SUBJECT_PREFIX} ${subject}" ${SMTP_TO}
}

function log() {
    "$@" 2>&1 | tee -a "$LOG"
}

function run_silently() {
    "$@" >/dev/null 2>&1
}

ESC_SEQ="\x1b["
COL_RED=$ESC_SEQ"31;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_RESET=$ESC_SEQ"39;49;00m"

function ok() {
    log echo -e "$COL_GREEN[ok]$COL_RESET $1"
}

function running() {
    log echo -en "$COL_BLUE ⇒ $COL_RESET $1..."
}

function warn() {
    log echo -e "$COL_YELLOW[warning]$COL_RESET $1"
}

function error() {
    log echo -e "$COL_RED[error]$COL_RESET $1"
    log echo -e "$2"
}

function notify_and_exit_on_error() {
    output=$(eval $1 2>&1)

    if [ $? -ne 0 ]; then
        error "$2" "$output"
        notify "$2" "$output" "$LOG"
        exit 2
    fi
}

# Backup steps
restic unlock

running "checking restic config"

run_silently restic cat config

if [ $? -ne 0 ]; then
    warn "restic repo either not initialized or erroring out"
    running "trying to initialize it"
    notify_and_exit_on_error "restic init" "Repo init failed"
fi

ok

running "restic backup"
notify_and_exit_on_error "restic backup --verbose /data" "Restic backup failed"
ok

running "checking consistency of restic repository"
notify_and_exit_on_error "restic check" "Restic check failed"
ok

running "removing outdated snapshots"
notify_and_exit_on_error "restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 3 --keep-yearly 3 --prune" "Restic forget failed"
ok

/usr/bin/find /var/log/restic/ -name "*.log" -type f -mmin +600 -exec rm -f {} \;
