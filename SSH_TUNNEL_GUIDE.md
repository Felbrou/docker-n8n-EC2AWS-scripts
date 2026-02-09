# SSH Tunnel Configuration for EC2 Connection

## EC2 Instance Details
- **Public DNS**: ec2-98-92-246-160.compute-1.amazonaws.com
- **Public IP**: 98.92.246.160

## Concepts Explained

### What is an SSH Tunnel?
An SSH tunnel creates a secure, encrypted connection between your local machine and a remote server (EC2 instance). It allows you to:
- Securely access services running on your EC2 instance
- Expose your local N8N instance through the EC2's public IP
- Forward ports between local and remote machines

### Two Common Use Cases

#### 1. **Local N8N → Access EC2 Services** (Local Port Forwarding)
Use this if you need your local N8N to connect to databases, APIs, or services running on EC2.

```bash
ssh -i ~/.ssh/your-key.pem -L LOCAL_PORT:localhost:REMOTE_PORT ec2-user@98.92.246.160
```

**Example**: Access a PostgreSQL database on EC2:
```bash
ssh -i ~/.ssh/your-key.pem -L 5432:localhost:5432 ec2-user@98.92.246.160
```
Now N8N can connect to `localhost:5432` which tunnels to EC2's PostgreSQL.

#### 2. **Expose Local N8N via EC2** (Remote Port Forwarding)
Use this if you want to make your local N8N accessible from the internet through EC2's public IP.

```bash
ssh -i ~/.ssh/your-key.pem -R REMOTE_PORT:localhost:LOCAL_PORT ec2-user@98.92.246.160
```

**Example**: Expose local N8N (port 5678) via EC2:
```bash
ssh -i ~/.ssh/your-key.pem -R 5678:localhost:5678 ec2-user@98.92.246.160
```

**Note**: You'll need to configure EC2's security groups to allow inbound traffic on port 5678.

## Prerequisites

### 1. SSH Key
Ensure you have your EC2 SSH key (.pem file):
```bash
chmod 400 ~/.ssh/your-ec2-key.pem
```

### 2. EC2 Security Group Configuration
In AWS Console → EC2 → Security Groups:
- Allow SSH (port 22) from your IP
- Allow N8N port (5678) if using remote forwarding
- Allow any other ports needed by your services

### 3. EC2 SSH Configuration (for Remote Forwarding)
Remote forwarding requires this setting on EC2. SSH into EC2 and edit:
```bash
sudo nano /etc/ssh/sshd_config
```

Add or uncomment:
```
GatewayPorts yes
```

Restart SSH service:
```bash
sudo systemctl restart sshd
```

## Keeping the Tunnel Alive

### Option 1: autossh (Recommended)
Install autossh to automatically reconnect if the tunnel drops:
```bash
# Install on Ubuntu/Debian
sudo apt-get install autossh

# Run with autossh
autossh -M 0 -i ~/.ssh/your-key.pem -L 5432:localhost:5432 ec2-user@98.92.246.160
```

### Option 2: systemd service
Create a systemd service to run the tunnel as a background service (see systemd example in project).

## Testing the Connection

### Test SSH Access
```bash
ssh -i ~/.ssh/your-key.pem ec2-user@98.92.246.160
```

### Test Port Forwarding
After establishing the tunnel, test if the port is accessible:
```bash
# For local forwarding
telnet localhost 5432

# For remote forwarding (from another machine)
telnet 98.92.246.160 5678
```

## Troubleshooting

### Connection Refused
- Check EC2 security group allows your IP
- Verify correct username (ec2-user, ubuntu, etc.)
- Ensure SSH key permissions are correct (chmod 400)

### Port Already in Use
```bash
# Find what's using the port
sudo lsof -i :5678

# Kill the process if needed
kill -9 <PID>
```

### Remote Forwarding Not Working
- Ensure `GatewayPorts yes` is set on EC2
- Check EC2 security group allows inbound traffic on the port
- Verify the service is listening on 0.0.0.0, not just 127.0.0.1

## Security Recommendations

1. **Use SSH Keys Only**: Disable password authentication
2. **Restrict IP Access**: Limit security group rules to your IP
3. **Use VPN**: Consider AWS VPN for better security
4. **Monitor Access**: Enable CloudTrail logging
5. **Rotate Keys**: Regularly update SSH keys
