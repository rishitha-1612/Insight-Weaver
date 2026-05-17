# Free 24/7 Deployment: Oracle Cloud Always Free

This is the recommended free deployment path for a public, always-on Insight Weaver demo.

Oracle Cloud Infrastructure Always Free includes Ampere A1 ARM compute resources. Oracle documents this as equivalent to **4 OCPUs and 24 GB RAM** for Always Free tenancies. This is enough to run the Docker Compose stack with Ollama on CPU using the lighter `gemma4:e2b` model.

## What You Get

- Public app URL through your server IP: `http://YOUR_SERVER_IP:8080`
- FastAPI backend: `http://YOUR_SERVER_IP:8000`
- Ollama API: `http://YOUR_SERVER_IP:11434`
- Dockerized frontend, backend, Ollama, model volume, uploads volume
- Full project behavior, not the Hugging Face safe-mode demo

## Expected Performance

This is CPU-only. The app will be public and usable, but Gemma responses can be slow.

Recommended model:

```env
OLLAMA_MODEL=gemma4:e2b
```

Use `gemma4:e4b` only if you accept a much larger model download and slower inference.

## Create the Free VM

In Oracle Cloud:

1. Create an **Always Free** account.
2. Create a compute instance.
3. Shape: `VM.Standard.A1.Flex`.
4. OCPUs: `4`.
5. Memory: `24 GB`.
6. Image: Ubuntu 22.04 or Ubuntu 24.04.
7. Boot volume: at least `100 GB` if available.
8. Add your SSH public key.
9. In the subnet security list or network security group, allow inbound:
   - TCP `22` for SSH
   - TCP `8080` for the app
   - optional TCP `8000` for direct backend debugging

## Deploy

SSH into the VM:

```bash
ssh ubuntu@YOUR_SERVER_IP
```

Install Git if needed:

```bash
sudo apt-get update
sudo apt-get install -y git
```

Clone and deploy:

```bash
git clone https://github.com/Venkat-023/Insight-Weaver.git
cd Insight-Weaver
cp .env.oracle-free.example .env
bash deploy/oracle-free/install.sh
```

Open:

```text
http://YOUR_SERVER_IP:8080
```

## Useful Commands

Check containers:

```bash
docker compose ps
```

Watch startup logs:

```bash
docker compose logs -f
```

Watch backend only:

```bash
docker compose logs -f backend
```

Watch Ollama model pull:

```bash
docker compose logs -f ollama
```

Restart:

```bash
docker compose restart
```

Update from GitHub:

```bash
git pull --ff-only origin main
docker compose up -d --build
```

## Notes

- First startup may take a long time because Ollama downloads the Gemma model.
- Keep `.env` set to `gemma4:e2b` for the free CPU server.
- Do not use Hugging Face safe-mode files for this deployment; use the normal `docker-compose.yml`.
- For HTTPS, attach a domain later and add Cloudflare DNS or a reverse proxy such as Caddy.
