# Raspberry Pi Deployment Guide

## Network Configuration

Your setup:
- **Pi Local IP**: 192.168.3.100
- **Public IP**: 66.90.142.106 
- **Domain**: media.nicholaskgraveley.com
- **Pi User**: onlythedregs
- **Pi Hostname**: media-server

## Required Port Forwarding Rules

Configure these rules on your router to forward traffic from your public IP to the Pi:

| External Port(s) | Internal IP | Internal Port(s) | Protocol | Service | Purpose |
|------------------|------------|------------------|-----------|---------|---------|
| 80 | 192.168.3.100 | 80 | TCP | Let's Encrypt | ACME challenge |
| 443 | 192.168.3.100 | 443 | TCP | OpenSIPS | WebSocket Secure (WSS) |
| 5060 | 192.168.3.100 | 5060 | UDP | OpenSIPS | SIP (optional, for debugging) |
| 10000-20000 | 192.168.3.100 | 10000-20000 | UDP | RTPEngine | RTP/SRTP Media |

## Deployment Steps

### 1. Update Environment Configuration

Edit `.env` file and verify your domain name:
```bash
PUBLIC_DOMAIN=media.nicholaskgraveley.com
```

### 2. TLS Certificates

For WebRTC to work, you need valid TLS certificates. Two options:

**Option A: Let's Encrypt with HTTP Challenge (Recommended)**

Now that you have port 80 forwarded, this is the best option:

```bash
# On the Pi (onlythedregs@media-server):
sudo apt update
sudo apt install certbot

# Stop any services using port 80 temporarily
sudo systemctl stop apache2 2>/dev/null || true
sudo systemctl stop nginx 2>/dev/null || true

# Generate certificate
sudo certbot certonly --standalone -d media.nicholaskgraveley.com

# Copy certificates to your project
sudo cp /etc/letsencrypt/live/media.nicholaskgraveley.com/fullchain.pem ./certs/
sudo cp /etc/letsencrypt/live/media.nicholaskgraveley.com/privkey.pem ./certs/
sudo chown onlythedregs:onlythedregs ./certs/*.pem
sudo chmod 644 ./certs/*.pem

# Verify certificates
openssl x509 -in ./certs/fullchain.pem -text -noout | grep -A 2 "Subject:"
```


**Option B: Let's Encrypt with HTTP Challenge (Needs port 80 forwarded)**
**Option B: Let's Encrypt with DNS Challenge (Alternative if HTTP challenge fails)**

First, identify your DNS provider:
```bash
# Check your domain's nameservers
dig NS media.nicholaskgraveley.com
# or
nslookup -type=NS media.nicholaskgraveley.com
```

Then install the appropriate plugin:

**For Cloudflare:**
```bash
sudo apt install certbot python3-certbot-dns-cloudflare
echo "dns_cloudflare_api_token = YOUR_ACTUAL_CLOUDFLARE_TOKEN" | sudo tee /etc/letsencrypt/cloudflare.ini
sudo chmod 600 /etc/letsencrypt/cloudflare.ini
sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini -d media.nicholaskgraveley.com
```

**For Route53 (AWS):**
```bash
sudo apt install certbot python3-certbot-dns-route53
sudo certbot certonly --dns-route53 -d media.nicholaskgraveley.com
```

**For DigitalOcean:**
```bash
sudo apt install certbot python3-certbot-dns-digitalocean
echo "dns_digitalocean_token = YOUR_DO_TOKEN" | sudo tee /etc/letsencrypt/do.ini
sudo chmod 600 /etc/letsencrypt/do.ini
sudo certbot certonly --dns-digitalocean --dns-digitalocean-credentials /etc/letsencrypt/do.ini -d media.nicholaskgraveley.com
```

**For other providers:** Check [Certbot DNS plugins](https://eff-certbot.readthedocs.io/en/stable/using.html#dns-plugins)

After successful certificate generation:
```bash
# Copy certificates
sudo cp /etc/letsencrypt/live/media.nicholaskgraveley.com/fullchain.pem ./certs/
sudo cp /etc/letsencrypt/live/media.nicholaskgraveley.com/privkey.pem ./certs/
sudo chown onlythedregs:onlythedregs ./certs/*.pem
```

**Option C: Self-signed (Testing Only)**
```bash
# If Let's Encrypt fails, use this for testing:
mkdir -p certs
openssl req -x509 -newkey rsa:4096 -keyout certs/privkey.pem -out certs/fullchain.pem -days 365 -nodes -subj "/CN=media.nicholaskgraveley.com"
chown onlythedregs:onlythedregs ./certs/*.pem
```

**Option D: Generate Certificate Elsewhere (Backup option)**
If you have access to a server with port 80 open, generate the certificate there and copy it to the Pi:
```bash
# On any machine with port 80 access
sudo certbot certonly --standalone -d media.nicholaskgraveley.com

# Then copy files to Pi
scp /etc/letsencrypt/live/media.nicholaskgraveley.com/fullchain.pem onlythedregs@192.168.3.100:~/certs/
scp /etc/letsencrypt/live/media.nicholaskgraveley.com/privkey.pem onlythedregs@192.168.3.100:~/certs/
```

### 3. Build and Deploy

```bash
# Build containers (ARM64 compatible)
docker-compose build

# Start services
docker-compose up -d

# Check status
docker-compose ps
```

### 4. Verify Connectivity

```bash
# Check WebSocket connectivity
curl -k wss://media.nicholaskgraveley.com

# View logs
docker-compose logs -f opensips
docker-compose logs -f rtpengine
```

## Pi-Specific Optimizations

### Memory Settings
Add to your Pi's `/boot/firmware/config.txt`:
```
# Increase GPU memory for video processing
gpu_mem=128

# Enable hardware H.264 decode
dtoverlay=vc4-kms-v3d
```

### Docker Daemon Configuration
Create `/etc/docker/daemon.json`:
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
```

## Firewall Configuration (UFW)

If using UFW on the Pi:
```bash
# Allow required ports
sudo ufw allow 443/tcp      # WSS
sudo ufw allow 5060/udp     # SIP (optional)
sudo ufw allow 10000:20000/udp  # RTP media

# Enable firewall
sudo ufw enable
```

## Troubleshooting

### Check Container Status
```bash
docker-compose ps
docker-compose logs containerName
```

### Test RTP Connectivity
```bash
# Check if RTPEngine is binding to ports
sudo netstat -unap | grep rtpengine
```

### Monitor Resource Usage
```bash
# CPU/Memory usage
htop

# Container resource usage  
docker stats
```

### Common Issues

1. **WebRTC not connecting**: Check TLS certificates and domain DNS
2. **No audio/video**: Verify UDP ports 10000-20000 are forwarded
3. **Pi overheating**: Ensure proper cooling, monitor `vcgencmd measure_temp`
4. **Memory issues**: Consider reducing video quality or adding swap

## Security Notes

- Use strong, unique domain and IP configurations
- Regularly update TLS certificates
- Monitor logs for suspicious activity
- Consider VPN access for administrative tasks
- Keep Docker images updated