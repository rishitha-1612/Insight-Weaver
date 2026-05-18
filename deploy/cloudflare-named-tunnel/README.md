# Stable Cloudflare Named Tunnel

Use this when the public demo must keep the same URL after Docker restarts.

## What This Solves

The default `public-tunnel` service uses a Cloudflare quick tunnel. Quick tunnels create temporary `trycloudflare.com` URLs and can change after restart.

A named Cloudflare Tunnel is different:

- the tunnel is stored in your Cloudflare account
- the hostname is stored in Cloudflare DNS
- the Docker container reconnects with a token
- the public URL remains the same after restarts

## Requirements

- A Cloudflare account
- A domain added to Cloudflare DNS
- Access to Cloudflare Zero Trust

## Dashboard Setup

1. Open Cloudflare Dashboard.
2. Go to **Zero Trust**.
3. Go to **Networks** -> **Tunnels**.
4. Create a tunnel.
5. Choose **Cloudflared**.
6. Name it, for example:

   ```text
   insight-weaver
   ```

7. Choose the Docker connector option and copy the generated token.
8. Add a public hostname:

   ```text
   insightweaver.yourdomain.com
   ```

9. Set the service/origin to:

   ```text
   http://frontend:80
   ```

10. Save the tunnel.

## Local `.env`

Create or edit `.env` in the repo root:

```env
OLLAMA_MODEL=gemma4:e4b
CLOUDFLARED_TOKEN=<paste-cloudflare-token-here>
```

Do not commit the real token.

## Start Named Tunnel Mode

Stop the temporary quick tunnel:

```powershell
docker compose stop public-tunnel
```

Start the stable named tunnel:

```powershell
docker compose --profile named-tunnel up -d named-tunnel
```

Or start the whole app with the named tunnel profile:

```powershell
docker compose --profile named-tunnel up -d
```

## Verify

```powershell
docker ps --filter name=gemma-hackathon
docker logs --tail 80 gemma-hackathon-named-tunnel
```

Then open:

```text
https://insightweaver.yourdomain.com
```

## Important Notes

- Keep the computer awake and plugged in.
- Display sleep is safe; system sleep is not.
- Docker Desktop and internet must stay running.
- The same named URL will survive container restarts.
- If the whole PC shuts down, the URL remains the same but the app is offline until the PC and Docker come back.
