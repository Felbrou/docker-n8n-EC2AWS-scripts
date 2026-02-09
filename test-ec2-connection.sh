#!/bin/bash
# Test SSH Connection to EC2

set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

SSH_KEY="${SSH_KEY_PATH:-~/.ssh/root-admin.pem}"
EC2_HOST="${EC2_PUBLIC_IP:-98.92.246.160}"
EC2_USER="${EC2_USER:-ubuntu}"

echo "🔍 Testing EC2 SSH connection..."
echo "   Host: ${EC2_HOST}"
echo "   User: ${EC2_USER}"
echo "   Key: ${SSH_KEY}"
echo ""

# Check if key file exists
if [ ! -f "$SSH_KEY" ]; then
    echo "❌ SSH key not found at: $SSH_KEY"
    exit 1
fi

# Check key permissions
PERMS=$(stat -c %a "$SSH_KEY" 2>/dev/null || stat -f %A "$SSH_KEY" 2>/dev/null)
if [ "$PERMS" != "400" ] && [ "$PERMS" != "600" ]; then
    echo "⚠️  SSH key has incorrect permissions: $PERMS"
    echo "   Fixing permissions..."
    chmod 400 "$SSH_KEY"
    echo "✅ Permissions fixed (set to 400)"
    echo ""
fi

# Test SSH connection
echo "🔐 Attempting SSH connection..."
if ssh -i "$SSH_KEY" \
    -o ConnectTimeout=10 \
    -o StrictHostKeyChecking=no \
    -o BatchMode=yes \
    ${EC2_USER}@${EC2_HOST} "echo '✅ Connection successful!'; uname -a"; then
    echo ""
    echo "🎉 SSH connection test passed!"
    echo ""
    echo "Next steps:"
    echo "1. Start local N8N: docker-compose up -d"
    echo "2. Expose N8N via EC2: ./tunnel-expose-n8n.sh"
    echo "   OR"
    echo "2. Access EC2 services: ./tunnel-access-ec2.sh"
else
    echo ""
    echo "❌ SSH connection failed!"
    echo ""
    echo "Troubleshooting:"
    echo "1. Verify EC2 security group allows SSH (port 22) from your IP"
    echo "2. Try different usernames: ubuntu, ec2-user, admin"
    echo "3. Check if the key pair matches the EC2 instance"
fi
