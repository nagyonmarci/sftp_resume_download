#!/bin/bash

SERVER="YOUR_FTP_SERVER"
USER="YOUR_USERNAME"
FILENAME="YOUR_FILENAME"
MAX_TRY=10
TRY=1

read -sp "Password: " PASS
echo

# Function to run an SFTP command using expect
sftp_expect() {
  local CMD=$1
  expect << EOF
    set timeout 600
    spawn sftp $USER@$SERVER
    expect {
      "Are you sure you want to continue connecting (yes/no)?" {
        send "yes\r"
        expect "password:"
        send "$PASS\r"
      }
      "password:" {
        send "$PASS\r"
      }
    }
    expect "sftp>"
    send "$CMD\r"
    expect "sftp>"
    send "bye\r"
    expect eof
EOF
}

# Get remote file size
REMOTE_LS=$(sftp_expect "ls -l")

REMOTE_SIZE=$(echo "$REMOTE_LS" | grep "$FILENAME" | sed -E 's/.*[[:space:]]([0-9]+)[[:space:]]+[A-Za-z]+[[:space:]]+[0-9]{1,2}[[:space:]]+[0-9]{2}:[0-9]{2}[[:space:]]+.*$/\1/')

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
  if [ -f "$FILENAME" ]; then
    LOCAL_SIZE=$(stat -f%z "$FILENAME")   # macOS-specific: stat -f%z
  fi
  echo "💾 Local file size: $LOCAL_SIZE bytes"

  if [ "$LOCAL_SIZE" -eq "$REMOTE_SIZE" ]; then
    echo "✅ Download complete!"
    break
  fi

  echo "🔄 Resuming download (${TRY}/${MAX_TRY})..."
  sftp_expect "reget $FILENAME"

  ((TRY++))
  sleep 2
done

if [ $TRY -gt $MAX_TRY ]; then
  echo "❌ Download failed after ${MAX_TRY} attempts."
fi
