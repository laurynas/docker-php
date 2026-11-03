# Docker PHP image

Based on official Docker PHP images.

Optimized for small instances. Allows passing Apache tuning via env variables.
Enables email sending via msmtp (PHP `sendmail_path`).

Extra PHP features enabled:
- MySQL (`mysqli`)
- GD (with JPEG support)
- Zip
- OPcache (7.x only; 8.x ships it as core)

Extra Apache modules enabled:
- rewrite
- remoteip

## Available Tags

| Tag    | PHP Version | Notes                              |
|--------|-------------|------------------------------------|
| `8.5`  | 8.5         | Active, auto-tracks upstream       |
| `7.4`  | 7.4 (EOL)   | EOL, hand-maintained CVE backports |

CI also pushes dated snapshot tags: `8.5-YYYYMMDD-<run_id>` and `7.4-YYYYMMDD-<run_id>-cve-patched`.

## CI Builds

- **8.5**: Monthly schedule (1st of month, 06:00 UTC) + push to `main` + manual dispatch
- **7.4**: Push to `main` + manual only (no timer — EOL, only changes with new patches)

Both versions are built for `linux/amd64` and `linux/arm64` in a single multi-arch step.

## Usage

Pull the image:

```bash
docker pull kurmisrainas/php:8.5   # or 7.4
```

### Apache Tuning (via environment variables)

| Variable                          | Default |
|-----------------------------------|---------|
| `APACHE_KEEP_ALIVE`               | On      |
| `APACHE_MAX_KEEP_ALIVE_REQUESTS`  | 10      |
| `APACHE_KEEP_ALIVE_TIMEOUT`       | 1       |
| `APACHE_START_SERVERS`            | 1       |
| `APACHE_MIN_SPARE_SERVERS`        | 1       |
| `APACHE_MAX_SPARE_SERVERS`        | 2       |
| `APACHE_MAX_REQUEST_WORKERS`      | 4       |
| `APACHE_MAX_CONNECTIONS_PER_CHILD`| 200     |

### Email

msmtp is configured by default to send via port 25 (no TLS, no auth) to host `mail`. Override by replacing `/etc/msmtprc` or mounting your own config.
