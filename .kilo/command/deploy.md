# Kilo CICD Deployment Commands

## Quick Commands

### Deploy to VM
- `/deploy-vm` - Deploy files to your VM via SSH
- `/deploy-status` - Check deployment status and logs
- `/test-ssh` - Test SSH connection to VM
- `/setup-secrets` - Guide for setting up GitHub secrets

### Workflow Management
- `/workflow-status` - Check GitHub Actions workflow status
- `/trigger-deploy` - Manually trigger deployment workflow

## Setup Steps

1. **Add SSH Key to GitHub Secrets**
   - Go to Repository Settings → Secrets and variables → Actions
   - Add `SSH_PRIVATE_KEY` with your VM's private key
   - Add `VM_IP` with your VM's IP address
   - Add `VM_USER` with SSH username (e.g., ubuntu, ec2-user, deploy)

2. **Configure VM**
   - Ensure Apache is installed: `sudo apt install apache2` (Ubuntu) or `sudo yum install httpd` (CentOS)
   - Ensure PHP is installed: `sudo apt install php libapache2-mod-php` (Ubuntu)
   - Open port 80 in firewall: `sudo ufw allow 80/tcp`
   - Ensure SSH key authentication works

3. **Test Deployment**
   - Push to main branch or manually trigger workflow
   - Check workflow logs in GitHub Actions tab
   - Visit `http://<VM_IP>` to verify deployment

## File Locations

- Workflow: `.github/workflows/deploy.yml`
- Local deploy script: `deploy.sh`
- Web files: `index.html`, `app.php`
- Kilo config: `.kilo/command/deploy.md`, `.kilo/agent/deploy-agent.md`
