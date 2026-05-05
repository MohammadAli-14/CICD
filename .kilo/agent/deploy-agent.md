# Kilo Deployment Agent

## Agent Overview

This agent provides advanced deployment capabilities for the Kilo CICD pipeline, including:
- SSH connection validation
- Remote server health checks
- Deployment verification
- Rollback capabilities
- Apache service management

## Usage

### Trigger Deployment
```
Trigger a new deployment to the production VM
```

### Check Deployment Status
```
Check the status of the last deployment
```

### Verify SSH Connection
```
Test SSH connectivity to the VM
```

### View Deployment Logs
```
Fetch and display recent deployment logs from GitHub Actions
```

### Rollback Deployment
```
Rollback to the previous stable version
```

## Prerequisites

Before using this agent, ensure:
1. GitHub repository secrets are configured (SSH_PRIVATE_KEY, VM_IP, VM_USER)
2. VM has Apache and PHP installed
3. SSH key-based authentication is working
4. Port 22 (SSH) and 80 (HTTP) are open in the firewall

## Error Handling

The agent will:
- Detect SSH connection failures
- Identify permission issues on the VM
- Report file transfer errors
- Suggest troubleshooting steps

## Integration

Works in conjunction with:
- `.github/workflows/deploy.yml` (GitHub Actions workflow)
- `deploy.sh` (local deployment script)
- `index.html` and `app.php` (deployed web files)
