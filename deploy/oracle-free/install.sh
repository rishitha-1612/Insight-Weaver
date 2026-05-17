#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f docker-compose.yml ]]; then
  echo "Run this script from the Insight-Weaver repository root."
  exit 1
fi

if [[ ! -f .env ]]; then
  cp .env.oracle-free.example .env
fi

echo "Installing Docker dependencies..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

if ! command -v docker >/dev/null 2>&1; then
  echo "Installing Docker Engine..."
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  . /etc/os-release
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

echo "Enabling Docker..."
sudo systemctl enable docker
sudo systemctl start docker

if command -v ufw >/dev/null 2>&1; then
  echo "Opening local firewall ports if UFW is active..."
  sudo ufw allow 22/tcp || true
  sudo ufw allow 8080/tcp || true
  sudo ufw allow 8000/tcp || true
fi

echo "Starting Insight Weaver..."
docker compose up -d --build

echo
echo "Deployment started."
echo "Check progress with: docker compose logs -f"
echo "Open the app at: http://YOUR_SERVER_IP:8080"
