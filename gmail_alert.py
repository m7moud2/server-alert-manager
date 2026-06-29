#!/usr/bin/env python3
import smtplib
import os
import sys
from email.message import EmailMessage

# 1. Read configuration from environment or .env file
env_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), '.env')
if os.path.exists(env_file):
    with open(env_file, 'r') as f:
        for line in f:
            if '=' in line and not line.startswith('#'):
                key, value = line.strip().split('=', 1)
                os.environ[key] = value

EMAIL_ADDRESS = os.environ.get('GMAIL_ADDRESS')
APP_PASSWORD = os.environ.get('GMAIL_APP_PASSWORD')

if not EMAIL_ADDRESS or not APP_PASSWORD:
    print("Error: GMAIL_ADDRESS or GMAIL_APP_PASSWORD not set in .env file.")
    sys.exit(1)

# 2. Get message from arguments
if len(sys.argv) < 2:
    print("Error: Please provide a message.")
    print("Usage: python3 gmail_alert.py 'Your alert message'")
    sys.exit(1)

alert_message = sys.argv[1]

# 3. Create the email message
msg = EmailMessage()
msg.set_content(alert_message)

msg['Subject'] = 'Server Alert'
msg['From'] = EMAIL_ADDRESS
# We send it to the same email address by default
msg['To'] = EMAIL_ADDRESS

# 4. Send the email using Gmail SMTP
try:
    with smtplib.SMTP_SSL('smtp.gmail.com', 465) as smtp:
        smtp.login(EMAIL_ADDRESS, APP_PASSWORD)
        smtp.send_message(msg)
    print("Email alert sent successfully!")
except Exception as e:
    print(f"Failed to send email: {e}")
    sys.exit(1)
