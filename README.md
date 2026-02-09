# N8N EC2 Project

Local N8N workflow automation connected to EC2 instance via secure SSH tunnels.

## 🎯 Project Overview

This project sets up N8N locally using Docker and provides secure SSH tunnel scripts to connect with your EC2 instance. You can either:
- **Expose your local N8N** to the internet through EC2's public IP
- **Access EC2 services** (databases, APIs) from your local N8N

## 🔑 Key Concepts

### SSH Tunnel (Secret Network Connection)
An SSH tunnel creates an **encrypted "secret" connection** between your local machine and EC2:
- All data is encrypted (secure)
- Acts as a private network bridge
- No need to expose services directly to the internet

### Two Tunnel Types

1. **Remote Port Forwarding** (`tunnel-expose-n8n.sh`)
   - Makes your LOCAL N8N accessible from the INTERNET via EC2
   - Useful for: webhooks, public access, testing from other devices
   - Connection: Internet → EC2:5678 → (tunnel) → Your Computer:5678

2. **Local Port Forwarding** (`tunnel-access-ec2.sh`)
   - Makes EC2 SERVICES accessible from your LOCAL N8N
   - Useful for: connecting to EC2 databases, APIs, services
   - Connection: Your Computer:5432 → (tunnel) → EC2:5432

## 📋 Prerequisites

- Docker and Docker Compose installed
- SSH key for EC2: `~/.ssh/root-admin.pem`
- EC2 instance: `98.92.246.160`

## 🚀 Quick Start

### 1. Test EC2 Connection
```bash
./test-ec2-connection.sh
```

### 2. Start N8N Locally
```bash
docker-compose up -d
```

Access N8N at: http://localhost:5678
- Username: `admin`
- Password: Check `.env` file

### 3. Choose Your Tunnel Setup

#### Option A: Expose Local N8N via EC2
```bash
./tunnel-expose-n8n.sh
```
Your N8N will be accessible at: `http://98.92.246.160:5678`

**Requirements:**
- EC2 security group must allow inbound traffic on port 5678
- EC2 must have `GatewayPorts yes` in `/etc/ssh/sshd_config`

#### Option B: Access EC2 Services
```bash
./tunnel-access-ec2.sh
```
Now your local N8N can connect to:
- PostgreSQL: `localhost:5432`
- MySQL: `localhost:3306`
- Redis: `localhost:6379`

## 📁 Project Structure

```
n8n-ec2-project/
├── docker-compose.yml          # N8N and PostgreSQL setup
├── .env                        # Configuration (DO NOT COMMIT)
├── .env.example               # Template for .env
├── tunnel-expose-n8n.sh       # Expose local N8N via EC2
├── tunnel-access-ec2.sh       # Access EC2 services locally
├── test-ec2-connection.sh     # Test SSH connection
├── SSH_TUNNEL_GUIDE.md        # Detailed tunnel documentation
└── README.md                  # This file
```

## 🔧 Configuration

### Environment Variables (.env)
```bash
# N8N credentials
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_password

# EC2 connection
EC2_PUBLIC_IP=98.92.246.160
SSH_KEY_PATH=~/.ssh/root-admin.pem
EC2_USER=ubuntu
```

### Customize Tunnel Ports
Edit the scripts to change forwarded ports:
- `tunnel-expose-n8n.sh`: Change `LOCAL_PORT` and `REMOTE_PORT`
- `tunnel-access-ec2.sh`: Modify the `FORWARDS` array

## 🛠️ Common Commands

```bash
# Start N8N
docker-compose up -d

# Stop N8N
docker-compose down

# View logs
docker-compose logs -f n8n

# Restart N8N
docker-compose restart n8n

# Test EC2 connection
./test-ec2-connection.sh

# SSH into EC2
ssh -i ~/.ssh/root-admin.pem ubuntu@98.92.246.160
```

## 🔒 Security Notes

1. **Never commit `.env`** - it contains passwords
2. **SSH key permissions**: Should be `400` (script auto-fixes this)
3. **EC2 Security Groups**: Only allow necessary ports from trusted IPs
4. **N8N Authentication**: Always enable basic auth in production
5. **Tunnel monitoring**: Tunnels disconnect when your computer sleeps

## 📊 EC2 Security Group Configuration

Your EC2 must allow:
- **SSH (22)**: From your IP for tunnel connection
- **N8N (5678)**: From anywhere (if using remote forwarding)
- **Other services**: As needed for your workflows

## 🐛 Troubleshooting

### SSH Connection Failed
```bash
# Check SSH key permissions
ls -la ~/.ssh/root-admin.pem

# Fix if needed
chmod 400 ~/.ssh/root-admin.pem

# Test with verbose output
ssh -vvv -i ~/.ssh/root-admin.pem ubuntu@98.92.246.160
```

### Tunnel Won't Stay Connected
- Install `autossh`: `sudo apt install autossh`
- Replace `ssh` with `autossh -M 0` in scripts

### Port Already in Use
```bash
# Find what's using the port
sudo lsof -i :5678

# Kill the process
kill -9 <PID>
```

### N8N Can't Connect to EC2 Database
1. Ensure tunnel is running: `./tunnel-access-ec2.sh`
2. Check port forwarding is active: `netstat -an | grep 5432`
3. Use `localhost` not `127.0.0.1` in N8N connection strings

## 📚 Additional Resources

- [N8N Documentation](https://docs.n8n.io/)
- [SSH_TUNNEL_GUIDE.md](./SSH_TUNNEL_GUIDE.md) - Detailed tunnel explanation
- [AWS EC2 Security Groups](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-security-groups.html)

## 🎓 Learning Path

1. ✅ Understand SSH tunnels (read SSH_TUNNEL_GUIDE.md)
2. ✅ Test EC2 connection
3. ✅ Start N8N locally
4. ✅ Create simple workflow in N8N
5. ✅ Set up tunnel based on your needs
6. ✅ Test connection through tunnel

## 💡 Use Cases

### Example 1: Access EC2 PostgreSQL from N8N
1. Start tunnel: `./tunnel-access-ec2.sh`
2. In N8N, add PostgreSQL node
3. Connect to: `localhost:5432`

### Example 2: Webhook from Internet
1. Start tunnel: `./tunnel-expose-n8n.sh`
2. In N8N, create webhook workflow
3. Use URL: `http://98.92.246.160:5678/webhook/your-path`

## 📞 Support

For detailed tunnel setup, see [SSH_TUNNEL_GUIDE.md](./SSH_TUNNEL_GUIDE.md)
