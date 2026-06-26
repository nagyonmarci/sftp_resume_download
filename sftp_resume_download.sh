#!/bin/bash

if [ $# -lt 2 ]; then
  echo "Usage: $0 <user@server> <remote_file> [local_dest]"
  exit 1
fi

USER_HOST=$1
REMOTE_FILE=$2
LOCAL_FILE=${3:-$(basename "$REMOTE_FILE")}
USER=${USER_HOST%@*}
SERVER=${USER_HOST#*@}
MAX_TRY=10
TRY=1

read -sp "Password: " PASS
echo

# Function to run an SFTP command using expect
sftp_expect() {
  local CMD=$1
  SFTP_PASS="$PASS" SFTP_USER="$USER" SFTP_SERVER="$SERVER" SFTP_CMD="$CMD" expect << 'EOF'
    set timeout 600
    spawn sftp -o StrictHostKeyChecking=accept-new $env(SFTP_USER)@$env(SFTP_SERVER)
    expect "password:"
    send "$env(SFTP_PASS)\r"
    expect "sftp>"
    send "$env(SFTP_CMD)\r"
    expect "sftp>"
    send "bye\r"
    expect eof
EOF
}

# Get remote file size
echo "🔌 Connecting to $SERVER..."
REMOTE_LS=$(sftp_expect "ls -l $REMOTE_FILE")

REMOTE_SIZE=$(echo "$REMOTE_LS" | grep -E "^[-d]" | sed -E 's/.*[[:space:]]([0-9]+)[[:space:]]+[A-Za-z]+[[:space:]]+[0-9]{1,2}[[:space:]]+[0-9]{2}:[0-9]{2}[[:space:]]+.*$/\1/')

if [[ ! "$REMOTE_SIZE" =~ ^[0-9]+$ ]]; then
  echo "❌ Failed to retrieve remote file size!"
  echo "SFTP ls -l output:"
  echo "$REMOTE_LS"
  exit 1
fi

echo "📦 Remote file size: $REMOTE_SIZE bytes"

# Retry download up to MAX_TRY times
while [ $TRY -le $MAX_TRY ]; do
  LOCAL_SIZE=0
  if [ -f "$LOCAL_FILE" ]; then
    LOCAL_SIZE=$(stat -f%z "$LOCAL_FILE" 2>/dev/null || stat -c%s "$LOCAL_FILE")
  fi
  echo "💾 Local file size: $LOCAL_SIZE bytes"

  if [ "$LOCAL_SIZE" -eq "$REMOTE_SIZE" ]; then
    echo "✅ Download complete!"
    break
  fi

  PCT=$(( LOCAL_SIZE * 100 / REMOTE_SIZE ))
  echo "🔄 Resuming download (${TRY}/${MAX_TRY}) — ${PCT}% complete..."
  sftp_expect "reget $REMOTE_FILE $LOCAL_FILE"

  ((TRY++))
  sleep 2
done

if [ $TRY -gt $MAX_TRY ]; then
  echo "❌ Download failed after ${MAX_TRY} attempts."
fi
