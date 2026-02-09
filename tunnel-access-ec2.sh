#!/bin/bash
# Access EC2 Services from Local N8N (Local Port Forwarding)
# This allows your local N8N to connect to services running on EC2

set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# SSH key and EC2 details
SSH_KEY="${SSH_KEY_PATH:-~/.ssh/root-admin.pem}"
EC2_HOST="${EC2_PUBLIC_IP:-98.92.246.160}"
EC2_USER="${EC2_USER:-ubuntu}"

# Port forwarding configuration
# Format: LOCAL_PORT:REMOTE_HOST:REMOTE_PORT
# Example: 5432:localhost:5432 (forward local 5432 to EC2's PostgreSQL on 5432)

# Default: Forward PostgreSQL, MySQL, Redis (common database ports)
FORWARDS=(
    "5432:localhost:5432"  # PostgreSQL
    "3306:localhost:3306"  # MySQL
    "6379:localhost:6379"  # Redis
)

echo "🚀 Setting up SSH tunnel to access EC2 services..."
echo ""
echo "📡 Port forwarding:"
for forward in "${FORWARDS[@]}"; do
    echo "   - localhost:${forward%%:*} → EC2:${forward##*:}"
done
echo ""
echo "💡 Now your local N8N can connect to these services via localhost"
echo "   Example: postgres://user:pass@localhost:5432/dbname"
echo ""
echo "📡 Establishing tunnel... (Press Ctrl+C to stop)"
echo ""

# Build SSH command with multiple -L flags
SSH_CMD="ssh -i $SSH_KEY"
for forward in "${FORWARDS[@]}"; do
    SSH_CMD="$SSH_CMD -L $forward"
done
SSH_CMD="$SSH_CMD -N -o ServerAliveInterval=60 -o ServerAliveCountMax=3 ${EC2_USER}@${EC2_HOST}"

# Execute SSH tunnel
eval "$SSH_CMD"
