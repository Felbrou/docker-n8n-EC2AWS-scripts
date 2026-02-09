#!/bin/bash
# Expose Local N8N via EC2 Public IP (Remote Port Forwarding)
# This makes your local N8N accessible from the internet through EC2

set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# SSH key and EC2 details
SSH_KEY="${SSH_KEY_PATH:-~/.ssh/root-admin.pem}"
EC2_HOST="${EC2_PUBLIC_IP:-98.92.246.160}"
EC2_USER="${EC2_USER:-ubuntu}"
LOCAL_PORT=5678
REMOTE_PORT=5678

echo "🚀 Setting up SSH tunnel to expose local N8N via EC2..."
echo "   Local N8N: http://localhost:${LOCAL_PORT}"
echo "   Public access: http://${EC2_HOST}:${REMOTE_PORT}"
echo ""
echo "⚠️  Make sure:"
echo "   1. EC2 security group allows inbound traffic on port ${REMOTE_PORT}"
echo "   2. N8N is running locally on port ${LOCAL_PORT}"
echo "   3. EC2 has 'GatewayPorts yes' in /etc/ssh/sshd_config"
echo ""
echo "📡 Establishing tunnel... (Press Ctrl+C to stop)"
echo ""

# Create SSH tunnel with remote port forwarding
ssh -i "$SSH_KEY" \
    -R ${REMOTE_PORT}:localhost:${LOCAL_PORT} \
    -N \
    -o ServerAliveInterval=60 \
    -o ServerAliveCountMax=3 \
    -o ExitOnForwardFailure=yes \
    ${EC2_USER}@${EC2_HOST}
