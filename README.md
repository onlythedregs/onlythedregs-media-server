# onlythedregs Media Server

A minimal WebRTC-to-SIP gateway for demonstrating VoIP architecture. Includes:

- **OpenSIPS** - WSS-enabled SIP proxy
- **RTPEngine** - WebRTC media relay (DTLS-SRTP ↔ RTP)
- **FreeSwitch** - Video playback server

## Architecture

```
Browser (WebRTC) ──WSS──► OpenSIPS ──SIP──► FreeSwitch
                 ──SRTP──► RTPEngine ──RTP──►
```

## Quick Start

### Prerequisites

- Docker & Docker Compose
- Domain name pointing to your server
- TLS certificates (Let's Encrypt recommended)

### 1. Generate TLS Certificates

```bash
sudo certbot certonly --standalone -d your-domain.com
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem ./certs/
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem ./certs/
sudo chmod 644 ./certs/*.pem
```

### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env with your domain and public IP
```

### 3. Add Your Video

Place your intro video at `./freeswitch/videos/intro.mp4`

Recommended format:
- Codec: H264 or VP8
- Resolution: 720p
- Duration: 30-60 seconds

### 4. Start Services

**Option A: Use Pre-built Images (Recommended for Pi)**
```bash
docker-compose up -d
# Images are automatically pulled from GitHub Container Registry
```

**Option B: Build Locally**
```bash
docker-compose build
docker-compose up -d
```

> **Note**: Pre-built multi-architecture images are automatically built and published via GitHub Actions when code is pushed to main. This makes Pi deployments much faster (~30 seconds vs 10+ minutes).

### 5. Verify

```bash
# Check all containers are running
docker-compose ps

# Test WSS connectivity
wscat -c wss://your-domain.com

# View OpenSIPS logs
docker-compose logs -f opensips
```

## Ports

| Port | Protocol | Service | Purpose |
|------|----------|---------|---------|
| 443 | TCP | OpenSIPS | WSS (WebSocket Secure) |
| 5060 | UDP | OpenSIPS | Internal SIP |
| 10000-20000 | UDP | RTPEngine | Media (RTP/SRTP) |

## Oracle Cloud Free Tier Setup

1. Create Always Free ARM instance:
   - Shape: VM.Standard.A1.Flex (2 OCPU, 12GB RAM)
   - Image: Canonical Ubuntu 24.04 LTS (aarch64)
   
2. Configure VCN Security List:
   - Ingress TCP 443 from 0.0.0.0/0
   - Ingress UDP 10000-20000 from 0.0.0.0/0
   
3. SSH into the instance and install Docker:
   ```bash
   # Update system
   sudo apt update && sudo apt upgrade -y
   
   # Install Docker
   sudo apt install -y docker.io docker-compose-v2
   sudo systemctl enable --now docker
   sudo usermod -aG docker $USER
   
   # Log out and back in for group changes
   exit
   ```

4. Install certbot for TLS:
   ```bash
   sudo apt install -y certbot
   sudo certbot certonly --standalone -d your-domain.com
   ```

5. Clone and deploy:
   ```bash
   git clone https://github.com/onlythedregs/onlythedregs-media-server.git
   cd onlythedregs-media-server
   
   # Copy certificates
   sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem ./certs/
   sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem ./certs/
   sudo chmod 644 ./certs/*.pem
   
   # Configure environment
   cp .env.example .env
   nano .env  # Set PUBLIC_IP and PUBLIC_DOMAIN
   
   # Start services
   docker compose up -d
   ```

## Raspberry Pi Deployment

For deployment on Raspberry Pi with port forwarding and NAT traversal:

**📋 See [PI_DEPLOYMENT.md](PI_DEPLOYMENT.md) for complete Pi setup guide**

Quick start:
```bash
# Configure environment
nano .env  # Set your PUBLIC_IP and INTERNAL_IP

# Run automated setup
chmod +x deploy-pi.sh
./deploy-pi.sh
```

## Troubleshooting

### No audio/video
- Check RTPEngine is running: `docker-compose logs rtpengine`
- Verify UDP ports 10000-20000 are open in firewall
- Check browser console for ICE connection failures

### WSS connection fails
- Verify TLS certs are valid: `openssl s_client -connect your-domain.com:443`
- Check OpenSIPS logs: `docker-compose logs opensips`

### FreeSwitch not answering
- Check dialplan: `docker-compose exec freeswitch fs_cli -x "show calls"`
- Verify video file exists: `docker-compose exec freeswitch ls -la /videos/`
