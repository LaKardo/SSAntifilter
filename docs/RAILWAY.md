# Railway deployment

This repository is prepared for Railway deployment through Dockerfile-based builds.

## Files added for Railway

- `railway.json` — Railway config-as-code. Forces Dockerfile builds and defines the basic deployment health check/restart policy.
- `.env.example` — example runtime variables. Do not store real secrets in this file.
- `.dockerignore` — keeps local runtime data and unnecessary files out of the Docker build context.
- `.gitignore` — prevents local environment files and generated runtime data from being committed.
- `docker-entrypoint.sh` — prepares writable runtime directories and keeps `config.json` on the persistent volume.

## Required Railway variables

Open your Railway service:

```text
Service -> Variables -> RAW Editor
```

Add these variables:

```env
PORT=8080
TZ=Europe/Moscow
SESSION_SECRET_KEY=replace_with_a_long_random_secret
SSA_DATA_DIR=rawdata
USE_HTTPS=0
```

Generate a strong `SESSION_SECRET_KEY` locally:

```bash
openssl rand -base64 48
```

On Windows PowerShell:

```powershell
-join ((48..122) | Get-Random -Count 64 | ForEach-Object {[char]$_})
```

Do not set internal HTTPS variables on Railway unless you intentionally terminate TLS inside the container. Railway public domains and custom domains normally provide HTTPS at the platform edge.

## Required Railway volume

Create a Railway Volume and mount it to:

```text
/app/rawdata
```

This path is required because SSAntifilter stores editable source data in `rawdata`, and the Docker entrypoint symlinks the generated admin `config.json` into this volume:

```text
/app/config.json -> /app/rawdata/config.json
```

Do not mount a volume directly to `/app`, because that can hide the application files copied into the Docker image.

## Public networking

Open:

```text
Service -> Settings -> Networking -> Public Networking -> Generate Domain
```

Use target port:

```text
8080
```

The application reads the `PORT` environment variable and defaults to `8080`.

## First login

After the first successful deployment, open Railway logs and find:

```text
Your login password: ...
```

Use this password to log in to the web interface.

Because `config.json` is stored on `/app/rawdata`, the password should survive redeploys as long as the Railway Volume remains attached.

## Useful endpoints

After deployment, these endpoints should be available under your Railway domain:

```text
/antifilter-ip.list
/antifilter-community-ip.list
/antifilter-community-domain.list
/proxy-domain.list
/direct-domain.list
/proxy-ip.list
/direct-ip.list

/antifilter-ip.yaml
/antifilter-community-ip.yaml
/antifilter-community-domain.yaml
/proxy-domain.yaml
/direct-domain.yaml
/proxy-ip.yaml
/direct-ip.yaml

/geoip.dat
/geosite.dat
```

## Troubleshooting

### The admin password changes after redeploy

Check that the Railway Volume is mounted to exactly:

```text
/app/rawdata
```

Then redeploy and verify that `/app/rawdata/config.json` exists in the container runtime.

### The service deploys but the URL does not open

Check:

```text
PORT=8080
```

Then verify Public Networking uses target port `8080`.

### Generated list files are missing

The app performs the first Antifilter update shortly after startup and then every 12 hours. You can also trigger `Update Antifilter` from the web interface.

### Custom edited files are lost

This means the volume is not attached correctly. The editable files must persist under:

```text
/app/rawdata/proxy-domain
/app/rawdata/direct-domain
/app/rawdata/proxy-ip
/app/rawdata/direct-ip
```
