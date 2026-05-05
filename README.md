# 🚀 Kilo CICD - Automated VM Deployment

**Quick Deploy:** Push to `main` → files automatically deployed to **20.187.148.79**

A complete GitHub Actions workflow for deploying HTML and PHP files to your Azure VM (IP: `20.187.148.79`, user: `azureuser`) via SSH with Apache.

## 📋 Table of Contents

- [Quick Start (Your VM)](#quick-start-your-vm)
- [Prerequisites](#prerequisites)
- [VM Setup for Azure](#vm-setup-for-azure)
- [GitHub Configuration](#github-configuration)
- [Workflow Details](#workflow-details)
- [Local Deployment](#local-deployment)
- [Troubleshooting](#troubleshooting)
- [Security](#security)
- [Project Structure](#project-structure)

## ⚡ Quick Start (Your VM)

### Your Settings
- **VM IP:** `20.187.148.79`
- **SSH User:** `azureuser`
- **Deploy Path:** `/var/www/html` (default Apache document root)

### 1. GitHub Secrets (DO THIS NOW)

Go to your GitHub repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add these **4 secrets**:

| Secret Name | Value | Required? |
|-------------|-------|-----------|
| `VM_IP` | `20.187.148.79` | ✅ Yes |
| `VM_USER` | `azureuser` | ✅ Yes |
| `SSH_PRIVATE_KEY` | Paste entire contents of your `.pem` file | ✅ Yes |
| `DEPLOY_PATH` | `/var/www/html` | ⚠️ Optional (default) |

**For SSH_PRIVATE_KEY:**
- Open your `.pem` file in Notepad
- Copy **everything** from `-----BEGIN RSA PRIVATE KEY-----` to `-----END RSA PRIVATE KEY-----`
- Paste into the secret value field
- Click "Add secret"

### 2. Prepare Your VM

SSH into your VM:

```bash
ssh -i /path/to/your-key.pem azureuser@20.187.148.79
```

Once logged in, run these commands on the VM:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Apache + PHP
sudo apt install -y apache2 php libapache2-mod-php

# Start and enable Apache
sudo systemctl start apache2
sudo systemctl enable apache2

# Give azureuser ownership of /var/www/html (needed for deployment)
sudo chown -R azureuser:azureuser /var/www/html

# Set standard permissions
sudo chmod -R 755 /var/www/html

# Allow SSH user to reload Apache (add to sudoers)
echo 'azureuser ALL=(ALL) NOPASSWD: /usr/sbin/apachectl, /usr/sbin/service apache2 reload, /bin/systemctl reload apache2' | sudo tee /etc/sudoers.d/azureuser-apache

# Verify PHP works
echo '<?php phpinfo(); ?>' | sudo tee /var/www/html/test.php
curl http://localhost/test.php | head -3

# Open firewall (if using UFW)
sudo ufw allow 22/tcp  # SSH (already open)
sudo ufw allow 80/tcp   # HTTP
sudo ufw reload

exit
```

**Important:** The `chown azureuser:azureuser /var/www/html` step gives your SSH user write access to the web directory. Without this, deployment will fail with "Permission denied".

### 3. Push to Deploy

```bash
git add .
git commit -m "Configure deployment to Azure VM"
git push origin main
```

Watch the workflow: **GitHub → Actions → Deploy to VM**

### 4. Verify

After workflow completes successfully:

- Visit: **http://20.187.148.79/**
- Visit: **http://20.187.148.79/app.php** (PHP status page)

---

## Prerequisites

This repository contains a production-ready CI/CD pipeline that automatically deploys your web files to a virtual machine whenever you push to the main branch.

**Features:**
- ✅ Automatic deployment on Git push
- ✅ SSH-based secure file transfer
- ✅ Apache web server integration
- ✅ PHP support with status monitoring
- ✅ Comprehensive error handling
- ✅ Detailed logging and notifications
- ✅ Manual workflow triggers
- ✅ Local deployment script included

## 📋 Prerequisites

### Required
- A VM with a public IP address (AWS EC2, DigitalOcean, Azure, etc.)
- Ubuntu 20.04+ or CentOS 7+ (other Linux distros may work)
- Apache web server installed
- PHP installed (for .php files)
- SSH access enabled
- GitHub repository

### Network Requirements
- Port 22 (SSH) open and accessible from GitHub Actions runners
- Port 80 (HTTP) open for web access
- Optional: Port 443 (HTTPS) if using SSL

## 🚀 Quick Start

### 1. Clone and Configure
```bash
git clone <your-repo-url>
cd CICD
# Add your HTML/PHP files
git add .
git commit -m "Initial commit"
git push origin main
```

### 2. Set Up VM (see VM Setup section below)

### 3. Configure GitHub Secrets
In your GitHub repository:
- Settings → Secrets and variables → Actions → New repository secret

Add these secrets:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `VM_IP` | Public IP of your VM | `123.45.67.89` |
| `VM_USER` | SSH username | `ubuntu` or `ec2-user` |
| `SSH_PRIVATE_KEY` | Complete private key (include all lines) | `-----BEGIN RSA PRIVATE KEY-----...` |
| `DEPLOY_PATH` | Web directory path (optional, defaults to `/var/www/html`) | `/var/www/html` |

### 4. Push to Deploy
```bash
git add .
git commit -m "Deploy to VM"
git push origin main
```

Watch the workflow run: Actions tab → Deploy to VM

## 🖥️ VM Setup

### Ubuntu/Debian (including Azure Ubuntu)

> **Note for Azure users:** Default user is `azureuser`, which has sudo rights.

1. **Update system**
```bash
sudo apt update && sudo apt upgrade -y
```

2. **Install Apache**
```bash
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo systemctl start apache2
```

3. **Install PHP**
```bash
sudo apt install php libapache2-mod-php php-mysql -y
sudo systemctl restart apache2
```

4. **Configure firewall**
```bash
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS (optional)
sudo ufw enable
```

5. **Create deployment user** (optional but recommended)
```bash
sudo adduser deploy
sudo usermod -aG sudo deploy
sudo su - deploy
```

6. **Set up SSH keys**
```bash
# On your local machine
ssh-keygen -t rsa -b 4096 -f ~/.ssh/kilo_deploy_key

# Copy public key to VM
ssh-copy-id -i ~/.ssh/kilo_deploy_key.pub deploy@<VM_IP>
```

7. **Set correct permissions**
```bash
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html
```

### CentOS/RHEL/Fedora

1. **Update system**
```bash
sudo yum update -y
```

2. **Install Apache**
```bash
sudo yum install httpd -y
sudo systemctl enable httpd
sudo systemctl start httpd
```

3. **Install PHP**
```bash
sudo yum install php php-mysqlnd -y
sudo systemctl restart httpd
```

4. **Configure firewall**
```bash
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

5. **Set up SSH keys** (same as Ubuntu)

6. **Permissions**
```bash
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html
```

## ⚙️ GitHub Configuration

### Repository Secrets

Go to your GitHub repository:
1. Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add each secret:

**SSH_PRIVATE_KEY** (most important)
- Open your private key file: `cat ~/.ssh/kilo_deploy_key`
- Copy entire content (including `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----`)
- Paste into secret value field
- Name: `SSH_PRIVATE_KEY`

**VM_IP**
- Your VM's public IP address
- Example: `192.168.1.100` or `ec2-123-45-67-89.compute-1.amazonaws.com`

**VM_USER**
- The user that has SSH access
- Common values: `ubuntu` (Ubuntu EC2), `ec2-user` (Amazon Linux), `deploy` (custom), `centos` (CentOS)

**DEPLOY_PATH** (optional)
- Path where files should be deployed
- Default: `/var/www/html`
- Only needed if using a different directory

### Testing Connection

Before pushing, test SSH from your local machine:
```bash
ssh -i ~/.ssh/kilo_deploy_key deploy@<VM_IP>
```

If this works, GitHub Actions will work too.

## 🔄 Workflow Details

### File: `.github/workflows/deploy.yml`

**Triggers:**
- `push` to `main` branch (automatic deployment)
- `workflow_dispatch` (manual trigger from GitHub UI)

**Steps:**
1. Checkout code
2. Set up SSH configuration and keys
3. Test SSH connection to VM
4. Create remote directory if needed
5. Upload `index.html` and `app.php` via rsync
6. Set file permissions (644 for files, 755 for directories)
7. Verify deployment
8. Clean up SSH key (security)

**Jobs:**
- `deploy`: Main deployment job running on `ubuntu-latest`

**Timeout:** 10 minutes (adjustable)

**Error Handling:**
- Fails fast on SSH connection errors
- Validates file existence before upload
- Reports clear error messages

## 📂 Local Deployment

Use the included `deploy.sh` script for local deployments (bypassing GitHub Actions).

### Usage

```bash
# Basic usage with environment variables
export VM_IP=192.168.1.100
export VM_USER=ubuntu
export SSH_KEY_PATH=~/.ssh/kilo_deploy_key
./deploy.sh

# Or with command-line arguments
./deploy.sh --ip 192.168.1.100 --user ubuntu --key ~/.ssh/kilo_deploy_key

# Custom deploy path
./deploy.sh --ip 192.168.1.100 --user ubuntu --key ~/.ssh/kilo_deploy_key --path /var/www/html

# Verbose mode
./deploy.sh --ip 192.168.1.100 --user ubuntu --key ~/.ssh/kilo_deploy_key --verbose

# Skip SSH check (if you know connection works)
./deploy.sh --ip 192.168.1.100 --user ubuntu --key ~/.ssh/kilo_deploy_key --skip-ssh-check
```

### Script Options

| Option | Description |
|--------|-------------|
| `-i, --ip` | VM IP address (required) |
| `-u, --user` | SSH username (required) |
| `-k, --key` | SSH private key path (default: ~/.ssh/id_rsa) |
| `-p, --path` | Remote deploy path (default: /var/www/html) |
| `-s, --skip-ssh-check` | Skip connection test |
| `-v, --verbose` | Enable debug output |
| `-h, --help` | Show help |

### Local Deployment Features

- ✅ Validates SSH key existence
- ✅ Tests SSH connection before copying
- ✅ Creates remote directory if needed
- ✅ Uploads files with proper permissions
- ✅ Provides detailed logging
- ✅ Handles errors gracefully

## 🔧 Troubleshooting

### Workflow Fails: "SSH connection failed"

**Possible causes:**
1. VM is not running or IP changed
2. SSH service not running: `sudo systemctl status ssh` (Ubuntu) or `sudo systemctl status sshd` (CentOS)
3. Firewall blocks port 22
4. Wrong username or IP in secrets
5. SSH key not added to VM's authorized_keys

**Solutions:**
```bash
# Check VM is reachable
ping <VM_IP>

# Test SSH manually
ssh -i ~/.ssh/kilo_deploy_key <VM_USER>@<VM_IP>

# Check SSH service on VM
sudo systemctl status ssh  # Ubuntu
sudo systemctl status sshd # CentOS/RHEL

# Verify authorized_keys
cat ~/.ssh/authorized_keys  # Should contain your public key
```

### Files Not Showing Up

**Check:**
1. Correct deploy path in secrets? Default is `/var/www/html`
2. Apache document root: `grep DocumentRoot /etc/apache2/sites-enabled/000-default.conf`
3. Permissions: `ls -la /var/www/html/` should show files
4. SELinux (CentOS/RHEL): `getenforce` (set to Permissive or configure properly)

### 403 Forbidden Error

**Fix permissions:**
```bash
# Ubuntu
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

# CentOS/RHEL
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html
```

### 404 Not Found

**Check Apache configuration:**
```bash
# Ubuntu
sudo a2enmod rewrite
sudo systemctl restart apache2

# Verify DocumentRoot
cat /etc/apache2/sites-enabled/000-default.conf | grep DocumentRoot
```

### PHP Not Executing

**Verify PHP is installed:**
```bash
php -v
# Should show PHP version

# Test PHP info
echo "<?php phpinfo(); ?>" > /var/www/html/test.php
curl http://localhost/test.php

# Restart Apache
sudo systemctl restart apache2  # Ubuntu
sudo systemctl restart httpd    # CentOS/RHEL
```

### Workflow "Permission denied (publickey)"

**Secrets issue:**
1. Verify `SSH_PRIVATE_KEY` secret includes full key (all lines)
2. Key should NOT have passphrase (or use ssh-agent)
3. Key should have correct format: `-----BEGIN RSA PRIVATE KEY-----`
4. No extra spaces or line breaks in secret

**Test locally with same key:**
```bash
ssh -i ~/.ssh/kilo_deploy_key <VM_USER>@<VM_IP>
```

If this fails, fix SSH before GitHub Actions will work.

### Apache Not Serving Updated Files

**Clear browser cache or force refresh:**
- Chrome/Firefox: `Ctrl+Shift+R` or `Ctrl+F5`
- Or use incognito mode

**Check Apache configuration:**
```bash
# Check for .htaccess conflicts
ls -la /var/www/html/.htaccess

# Check Apache error logs
sudo tail -f /var/log/apache2/error.log  # Ubuntu
sudo tail -f /var/log/httpd/error_log    # CentOS/RHEL
```

## 🔒 Security

### SSH Key Security

1. **Use a dedicated deploy key** (not your personal SSH key)
2. **Set proper permissions on private key:**
   ```bash
   chmod 600 ~/.ssh/kilo_deploy_key
   chmod 644 ~/.ssh/kilo_deploy_key.pub
   ```
3. **Never commit private keys** - they're in `.gitignore` by default
4. **Rotate keys periodically**
5. **Restrict key usage** in `authorized_keys` (optional):
   ```
   command="/usr/bin/rsync --server -v . /var/www/html",no-port-forwarding,no-X11-forwarding,no-agent-forwarding ssh-rsa AAAAB3NzaC1...
   ```

### VM User Permissions

Your deployment user (`azureuser`) needs:

```bash
# Ownership of web directory (ONE-TIME setup on VM)
sudo chown -R azureuser:azureuser /var/www/html

# Passwordless sudo for Apache reload (optional but recommended)
echo 'azureuser ALL=(ALL) NOPASSWD: /usr/sbin/apachectl, /usr/sbin/service apache2 reload' | sudo tee /etc/sudoers.d/azureuser-apache
```

### VM Security

1. **Disable password authentication:**
   ```bash
   sudo nano /etc/ssh/sshd_config
   # Set: PasswordAuthentication no
   sudo systemctl restart ssh
   ```

2. **Change default SSH port** (optional):
   ```bash
   sudo nano /etc/ssh/sshd_config
   # Change: Port 2222
   sudo systemctl restart ssh
   ```

3. **Use UFW/Firewall:**
   ```bash
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp
   sudo ufw enable
   ```

4. **Keep system updated:**
   ```bash
   sudo apt update && sudo apt upgrade -y  # Ubuntu
   sudo yum update -y                      # CentOS/RHEL
   ```

5. **Install fail2ban** (prevents brute force):
   ```bash
   sudo apt install fail2ban -y  # Ubuntu
   sudo systemctl enable fail2ban
   ```

### GitHub Secrets

- Never log secrets in workflow (use `::add-mask::` if needed)
- Use `actions/checkout@v4` for secure code checkout
- Secrets are encrypted and only exposed to selected workflows
- Audit secret access in repository settings

## 🎨 Customization

### Changing Deploy Path

Update secret `DEPLOY_PATH` or modify workflow:
```yaml
- name: Deploy to VM
  run: |
    DEPLOY_PATH="/var/www/myapp"
    # ... rest of script
```

### Adding More Files

Edit both:
1. `.github/workflows/deploy.yml` - update FILES array
2. `deploy.sh` - update FILES_TO_DEPLOY array

```bash
FILES_TO_DEPLOY=("index.html" "app.php" "style.css" "script.js" "assets/")
```

### Multiple Environments

Create separate workflows:
- `.github/workflows/deploy-staging.yml`
- `.github/workflows/deploy-production.yml`

Use different secrets:
- `STAGING_VM_IP`, `PROD_VM_IP`
- `STAGING_VM_USER`, `PROD_VM_USER`

### Adding SSL/HTTPS

1. Get SSL certificate on VM:
```bash
sudo apt install certbot python3-certbot-apache -y
sudo certbot --apache -d yourdomain.com
```

2. Auto-renewal:
```bash
sudo certbot renew --dry-run
```

3. Update Apache to redirect HTTP to HTTPS in `/etc/apache2/sites-enabled/000-default.conf`:
```apache
<VirtualHost *:80>
    ServerName yourdomain.com
    Redirect permanent / https://yourdomain.com/
</VirtualHost>
```

### Database Integration

If your PHP app needs a database:

1. **Set up MySQL/MariaDB on VM:**
```bash
sudo apt install mysql-server -y
sudo mysql_secure_installation
```

2. **Create database:**
```bash
sudo mysql -e "CREATE DATABASE myapp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER 'myapp'@'localhost' IDENTIFIED BY 'strong_password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON myapp.* TO 'myapp'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"
```

3. **Import schema:**
```bash
mysql -u myapp -p myapp < schema.sql
```

4. **Update config in your PHP files** (use environment variables for security)

### Email Notifications

Add to workflow to send email on deployment:
```yaml
- name: Send notification
  if: always()
  run: |
    curl --url 'smtp://smtp.gmail.com:587' \
         --ssl-reqd \
         --mail-from 'deploy@yourdomain.com' \
         --mail-rcpt 'admin@yourdomain.com' \
         --user 'user:password' \
         --upload-file mail.txt
```

Or use Slack/MS Teams webhooks.

## 📁 Project Structure

```
CICD/
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions workflow
├── .kilo/
│   ├── command/
│   │   └── deploy.md           # Kilo command reference
│   └── agent/
│       └── deploy-agent.md     # Kilo agent instructions
├── index.html                  # Main landing page
├── app.php                     # PHP status/info page
├── deploy.sh                   # Local deployment script
├── README.md                   # This file
└── .gitignore                  # Git ignore rules
```

### File Descriptions

| File | Purpose |
|------|---------|
| `.github/workflows/deploy.yml` | CI/CD pipeline - runs on every push to main |
| `deploy.sh` | Manual deployment script for local use |
| `index.html` | Welcome page showing deployment status |
| `app.php` | PHP info page - confirms PHP is working |
| `.kilo/command/deploy.md` | Kilo CLI command reference |
| `.kilo/agent/deploy-agent.md` | Kilo agent capabilities |

## 📊 Monitoring

### Check Workflow Runs
1. Go to GitHub repository
2. Click "Actions" tab
3. Select "Deploy to VM" workflow
4. View recent runs and logs

### View Apache Logs on VM
```bash
# Access logs
sudo tail -f /var/log/apache2/access.log  # Ubuntu
sudo tail -f /var/log/httpd/access_log    # CentOS/RHEL

# Error logs
sudo tail -f /var/log/apache2/error.log  # Ubuntu
sudo tail -f /var/log/httpd/error_log    # CentOS/RHEL
```

### Check Deployment Health
Visit these URLs:
- `http://<VM_IP>/` - Main page
- `http://<VM_IP>/app.php` - PHP status

## 🔄 Rollback

If deployment breaks:

### Via GitHub Actions
1. Go to Actions tab
2. Find previous successful run
3. Click "Re-run all jobs" (if needed)
4. Or manually rollback by checking out previous commit and pushing

### Manual Rollback
```bash
# SSH to VM
ssh <VM_USER>@<VM_IP>

# View git history (if repo cloned on VM)
cd /var/www/html
git log --oneline

# Reset to previous commit
git reset --hard <commit-hash>

# Or replace files manually
# (copy from local backup)
```

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Apache HTTP Server Docs](https://httpd.apache.org/docs/)
- [PHP Manual](https://www.php.net/manual/)
- [Ubuntu Server Guide](https://ubuntu.com/server/docs)
- [CentOS Documentation](https://docs.centos.org/)

## 🤝 Support

For issues or questions:
1. Check Troubleshooting section above
2. Review GitHub Actions workflow logs
3. Check VM Apache/PHP logs
4. Ensure all prerequisites are met
5. Test SSH connection manually

## 📄 License

This project is open source. Modify as needed for your use case.

---

**Last Updated:** 2026-05-05
**Version:** 1.0.0
**Maintained by:** Kilo Org
