#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
ALERT_SCRIPT="${SCRIPT_DIR}/gmail_alert.py"

# Load Configuration File
CONFIG_FILE="${SCRIPT_DIR}/monitor.conf"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Error: Configuration file monitor.conf not found!"
    exit 1
fi

SERVER_NAME=$(hostname)
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "Starting Server Monitor..."

CURRENT_DISK_USAGE=$(df / | grep / | awk '{ print $5}' | sed 's/%//g')

if [ "$CURRENT_DISK_USAGE" -gt "$MAX_DISK_USAGE" ]; then
    MESSAGE="Server: ${SERVER_NAME}
Time: ${DATE}

DISK SPACE ALERT
Disk space usage is critically high at ${CURRENT_DISK_USAGE}%!
Please check the server immediately."
    
    echo "Disk usage is high ($CURRENT_DISK_USAGE%). Sending email alert..."
    python3 "$ALERT_SCRIPT" "$MESSAGE"
else
    echo "Disk usage is normal: ${CURRENT_DISK_USAGE}%"
fi

# 2. Check RAM Usage (Alert if free memory is less than MIN_FREE_RAM)
# getting free ram in MB on linux
FREE_RAM_MB=$(free -m | awk 'NR==2{print $4}')

if [ "$FREE_RAM_MB" -lt "$MIN_FREE_RAM" ]; then
    MESSAGE="Server: ${SERVER_NAME}
Time: ${DATE}

MEMORY ALERT
Free RAM is critically low at ${FREE_RAM_MB}MB!
Please check the server immediately."
    
    echo "Free memory is low (${FREE_RAM_MB}MB). Sending email alert..."
    python3 "$ALERT_SCRIPT" "$MESSAGE"
else
    echo "Free memory is normal: ${FREE_RAM_MB}MB"
fi


# Direct test
# python3 "$ALERT_SCRIPT" "This is a test alert from the Gmail Alert Manager on $SERVER_NAME."
echo "Server monitoring finished."
