# one-click Coder VMs

This packages a VM image with Coder and Caddy for LetsEncrypt/certificate management.

By default, Coder will run on your Droplet's public IPv4 address with a self-signed certificate: [https://your_droplet_public_ipv4/login](https://your_droplet_public_ipv4/login)

Log in with the following username and password: `admin:coder1235`. Upon logging in, you will be prompted to change your password. 

## Add a domain (optional)

1. Point your DNS records (`coder.yourdomain.com` `*.coder.yourdomain.com`) to the Droplet's public IPv4 address.
2. Navigate to the domain, Caddy should automatically provision a TLS certificate. (we recommend using an incognito window in the beginning to initial caching issues)

## Enable [dev URLs](https://coder.com/docs/coder/latest/workspaces/devurls) (optional)

1. SSH into your Droplet: `ssh root@your_droplet_public_ipv4`

2. Follow instructions to modify `coder/docker-compose.yaml` and set

   ```yaml
   - DEVURL_HOST=*.coder.yourdomain.com
   ```

3. Modify `coder/Caddyfile` to specify your email address for LetsEncrypt.

4. Restart Coder and Caddy:

   ```bash
   cd $HOME/coder && docker-compose restart
   ```

## Harden your configuration (recommended)

1. SSH into your Droplet: `ssh root@your_droplet_public_ipv4`

2. Follow instructions to modify `coder/Caddyfile` to disable "internal" (self-signed) certificates and add your email for LetsEncrypt.

3. Replace `https:// {` with `coder.yourdomain.com, *.coder.yourdomain.com {` to limit the proxy to your domain(s).

4. Restart Coder and Caddy:

   ```bash
   cd $HOME/coder && docker-compose restart
   ```

## Use a wildcard certificate

By default, Caddy's [On-Demand TLS](https://caddyserver.com/docs/automatic-https#on-demand-tls) will be used to generate certificates for dev URLs. This zero-configuration options works well, but introduces \~10 second delays or [rate limiting](https://letsencrypt.org/docs/rate-limits/) when a developer visits a newly-created dev URL.

For best results, consider configuring [ZeroSSL with Caddy](https://caddy.community/t/using-zerossls-acme-endpoint/9406) or [build a Caddy image](https://github.com/docker-library/docs/tree/master/caddy#adding-custom-caddy-modules) with the module for your DNS provider.

Stay tuned for a [future release](https://github.com/bpmct/c4d-packer/releases) with improved steps for wildcard/custom certificates.

## Use a managed Postgres database (optional)

1. SSH into your Droplet: `ssh root@your_droplet_public_ipv4`

2. Modify `coder/docker-compose.yaml` and [follow our docs](https://coder.com/docs/coder/latest/setup/docker#use-an-external-postgresql-database) to configure your managed database with Coder for Docker.

3. Restart Coder and Caddy:

   ```bash
   cd $HOME/coder && docker-compose restart
   ```

Stay tuned for a [future release](https://github.com/bpmct/c4d-packer/releases) with built-in support for DigitalOcean managed DBs.
