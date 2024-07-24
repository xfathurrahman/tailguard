### Flyio - AdguardHome - Tailscale

#### Add-on Features    

- [x] Auto Backup AdguardHome Configuration to s3 compatible storage (Restic)
- [x] Get Mail Notification when Backup is failed
- [x] Connect from anywhere using Tailscale private network

#### Installation

1. Launch the app

```bash
fly launch --no-deploy
```

- I recommended to use 2GB of memory for this app

2. Fill the env variables with your own values

- copy the `.env.example` to `.env` and fill the values

your final `.env` file should look like this:

```bash

TAILSCALE_HOSTNAME=tailguard
TAILSCALE_DNS=mother-father.ts.net
TAILSCALE_AUTHKEY=tskey-auth-xxxxxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
SMTP_HOST=smtp.resend.com
SMTP_PORT=587
SMTP_USERNAME=resend
SMTP_FROM=support@fathur.dev
SMTP_TO=info@fathur.dev
SMTP_PASSWORD=xxxxxxxxxxxx / apikey
RESTIC_REPOSITORY=s3://xxxxxxxxxxxxxxxxxxxxx.r2/s3/bz.cloudflarestorage.com/backup/adguard
RESTIC_PASSWORD=xxxxxxxxxxxxxxxx
AWS_ACCESS_KEY_ID=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

```

- for mail i'm using [Resend.com](https://resend.com) you can use your own smtp server
- for s3 compatible storage i'm using [Cloudflare R2](https://www.cloudflare.com/r2/) you can use your own s3 compatible storage
- for tailscale you can get the authkey from [Tailscale](https://login.tailscale.com/admin/authkeys)

3. Set the env variables to the fly.io secrets 

```bash
cat .env | fly secrets import
```

4. Deploy the app

```bash
fly deploy
```