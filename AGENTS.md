# Appepi

This file provides guidance to AI coding agents working with this repository.

## What is Appepi?

Appepi is the home page that launches users to other .appepi.com subdomain applications on the root url which is public. The authenticated side is where the admin will have a full suite of monitoring tools for monitoring the other applications on the subdomins.

## Development Commands

### Setup and Server
```bash
bin/setup              # Initial setup (installs gems, creates DB, loads schema)
bin/dev                # Start development server (runs on port 3006)
```

<!-- Development URL: http://fizzy.localhost:3006
Login with: david@example.com (development fixtures), password will appear in the browser console -->

### Testing
```bash
bin/rails test                    # Run unit tests (fast)
bin/rails test test/path/file_test.rb  # Run single test file
# bin/rails test:system             # Run system tests (Capybara + Selenium)
bin/ci                            # Run full CI suite (style, security, tests)

# For parallel test execution issues, use:
PARALLEL_WORKERS=1 bin/rails test
```

CI pipeline (`bin/ci`) runs:
1. Rubocop (style)
2. Bundler audit (gem security)
3. Importmap audit
4. Brakeman (security scan)
5. Application tests
<!-- 6. System tests -->

### Database
```bash
bin/rails db:fixtures:load   # Load fixture data
bin/rails db:migrate          # Run migrations
bin/rails db:reset            # Drop, create, and load schema
```

### Other Utilities
```bash
# bin/rails dev:email          # Toggle letter_opener for email preview
bin/jobs                     # Manage Solid Queue jobs
# bin/kamal deploy             # Deploy (requires 1Password CLI for secrets)
```

## Deploy

Default branch: `main`
Image Creation: `appepi/.github/workflows/push-image.yml`
Once deploys the image from ghcr.io/epidevops/appepi:main to the server automatically.

## Infrastructure Architecture

### Hetzner Server

- **Name:** appepi-server
- **Type:** CPX 32 — 4 vCPU, 8 GB RAM, 160 GB disk (shared, x86)
- **OS:** Ubuntu 24.04
- **Location:** Helsinki, Finland (hel1-dc2)
- **IPs:** see `.claude/infrastructure.md` (gitignored)
- **Firewall (appepi-firewall):**
  - SSH port 22: restricted to a single trusted IP only
  - HTTP port 80: Cloudflare IPs only
  - HTTPS port 443: Cloudflare IPs only
  - All direct internet traffic is blocked — traffic must flow through Cloudflare

### Docker & Once

[basecamp/once](https://github.com/basecamp/once) v0.1.3 manages all apps on the server.

**Proxy:** `basecamp/kamal-proxy:once-01` (container: `once-proxy`)
- Listens on 0.0.0.0:80 and 0.0.0.0:443
- Routes traffic to app containers by hostname
- Handles TLS termination from Cloudflare (strict mode)

**Running containers:**

| Container | Image | Purpose |
|-----------|-------|---------|
| once-app-appepi.937647 | ghcr.io/epidevops/appepi:main | This app (appepi.com) |
| once-app-fizzy.5147cc | ghcr.io/basecamp/fizzy | Basecamp Fizzy |
| once-app-writebook.131013 | ghcr.io/basecamp/writebook | Basecamp Writebook |
| once-proxy | basecamp/kamal-proxy:once-01 | Reverse proxy |

**Once commands:**
```bash
once list                  # List installed apps
once deploy <app>          # Deploy/update an app
once start/stop <app>      # Start or stop an app
once backup/restore <app>  # Backup or restore app data
```

**Docker volumes:** `once-app-appepi.937647`, `once-app-fizzy.5147cc`, `once-app-writebook.131013`, `once-proxy`

**Docker network:** `once` (bridge)

### Cloudflare

- **Zone:** appepi.com (active, full setup)
- **Nameservers:** kenneth.ns.cloudflare.com, lily.ns.cloudflare.com
- **SSL:** Strict (end-to-end encryption required)
- **Always HTTPS:** on
- **Min TLS:** 1.2

**DNS Records:**

| Type | Name | Value | Proxied |
|------|------|-------|---------|
| A | appepi.com | floating IP (see `.claude/infrastructure.md`) | Yes |
| A | *.appepi.com | floating IP (see `.claude/infrastructure.md`) | Yes |
| MX | send.appepi.com | feedback-smtp.us-east-1.amazonses.com | No |
| TXT | resend._domainkey.appepi.com | DKIM key (Resend) | No |
| TXT | send.appepi.com | SPF for Amazon SES | No |

Wildcard DNS means all `*.appepi.com` subdomains automatically route to the server — once/kamal-proxy handles routing by hostname.

**Email:** Resend (via Amazon SES) for transactional email on `send.appepi.com`.

## Tools

**Always perform server-side work by SSHing into the Hetzner server. Do not run infrastructure or deployment commands locally.**

### Hetzner Server

SSH connection details, hcloud CLI config, and Cloudflare credentials are in `.claude/infrastructure.md` (gitignored).

### Chrome MCP (Local Dev)

<!-- TODO -->

<!-- URL: `http://fizzy.localhost:3006`
Login: david@example.com (passwordless magic link auth - check rails console for link) -->

Use Chrome MCP tools to interact with the running dev app for UI testing and debugging.

## Coding style

@STYLE.md
