#!/bin/bash
#
# Kilo CICD Deployment Script
# Deploys HTML/PHP files to a remote VM via SSH
#
# Usage: ./deploy.sh [options]
# Options:
#   -h, --help     Show this help message
#   -i, --ip       VM IP address (or set VM_IP env var)
#   -u, --user     SSH username (or set VM_USER env var)
#   -k, --key      SSH private key path (or set SSH_KEY_PATH env var)
#   -p, --path     Remote deployment path (default: /var/www/html)
#   -s, --skip-ssh Check Skip SSH connection check (default: false)
#
# Environment Variables:
#   VM_IP           VM IP address
#   VM_USER         SSH username
#   SSH_KEY_PATH    Path to SSH private key
#   DEPLOY_PATH     Remote deployment path
#   SKIP_SSH_CHECK  Skip SSH connectivity check
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
VM_IP="${VM_IP:-}"
VM_USER="${VM_USER:-}"
SSH_KEY_PATH="${SSH_KEY_PATH:-~/.ssh/id_rsa}"
DEPLOY_PATH="${DEPLOY_PATH:-/var/www/html}"
SKIP_SSH_CHECK="${SKIP_SSH_CHECK:-false}"
VERBOSE="${VERBOSE:-false}"

# Files to deploy
FILES_TO_DEPLOY=("index.html" "app.php")

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    cat << EOF
Kilo CICD Deployment Script

Usage: ./deploy.sh [options]

Options:
  -h, --help            Show this help message
  -i, --ip IP           VM IP address (or set VM_IP env var)
  -u, --user USER       SSH username (or set VM_USER env var)
  -k, --key PATH        SSH private key path (or set SSH_KEY_PATH env var)
  -p, --path PATH       Remote deployment path (default: /var/www/html)
  -s, --skip-ssh-check  Skip SSH connection check
  -v, --verbose         Enable verbose output

Environment Variables:
  VM_IP                 VM IP address
  VM_USER               SSH username
  SSH_KEY_PATH          Path to SSH private key
  DEPLOY_PATH           Remote deployment path
  SKIP_SSH_CHECK        Skip SSH connectivity check

Examples:
  ./deploy.sh --ip 192.168.1.100 --user ubuntu --key ~/.ssh/mykey.pem
  VM_IP=192.168.1.100 VM_USER=deploy ./deploy.sh

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -i|--ip)
            VM_IP="$2"
            shift 2
            ;;
        -u|--user)
            VM_USER="$2"
            shift 2
            ;;
        -k|--key)
            SSH_KEY_PATH="$2"
            shift 2
            ;;
        -p|--path)
            DEPLOY_PATH="$2"
            shift 2
            ;;
        -s|--skip-ssh-check)
            SKIP_SSH_CHECK="true"
            shift
            ;;
        -v|--verbose)
            VERBOSE="true"
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$VM_IP" ]]; then
    log_error "VM IP address is required. Use --ip or set VM_IP environment variable."
    show_help
    exit 1
fi

if [[ -z "$VM_USER" ]]; then
    log_error "SSH username is required. Use --user or set VM_USER environment variable."
    show_help
    exit 1
fi

# Expand tilde in SSH key path
SSH_KEY_PATH="${SSH_KEY_PATH/#\~/$HOME}"

# Check if SSH key exists
if [[ ! -f "$SSH_KEY_PATH" ]]; then
    log_error "SSH key not found at: $SSH_KEY_PATH"
    exit 1
fi

# Set SSH options
SSH_OPTS="-i $SSH_KEY_PATH -o StrictHostKeyChecking=no -o ConnectTimeout=10 -o BatchMode=yes"

if [[ "$VERBOSE" == "true" ]]; then
    SSH_OPTS="$SSH_OPTS -v"
fi

log_info "Starting deployment to VM..."
log_info "Target: $VM_USER@$VM_IP"
log_info "Deploy path: $DEPLOY_PATH"
log_info "SSH Key: $SSH_KEY_PATH"

# Check SSH connectivity
if [[ "$SKIP_SSH_CHECK" != "true" ]]; then
    log_info "Testing SSH connection..."
    if ssh $SSH_OPTS "$VM_USER@$VM_IP" 'echo SSH_OK' 2>/dev/null | grep -q 'SSH_OK'; then
        log_success "SSH connection established"
    else
        log_error "Failed to connect via SSH. Please check:"
        log_error "  - VM is running and accessible at $VM_IP"
        log_error "  - SSH service is running on port 22"
        log_error "  - SSH key is correct and has proper permissions"
        log_error "  - User '$VM_USER' exists on the VM"
        exit 1
    fi
else
    log_warning "Skipping SSH connectivity check"
fi

# Verify remote directory exists or create it
log_info "Ensuring remote directory exists..."
ssh $SSH_OPTS "$VM_USER@$VM_IP" "sudo mkdir -p $DEPLOY_PATH && sudo chown $VM_USER:$VM_USER $DEPLOY_PATH" || {
    log_warning "Could not create/verify directory. Trying without sudo..."
    ssh $SSH_OPTS "$VM_USER@$VM_IP" "mkdir -p $DEPLOY_PATH" || {
        log_error "Failed to create remote directory: $DEPLOY_PATH"
        exit 1
    }
}

# Deploy files
log_info "Deploying files to $VM_USER@$VM_IP:$DEPLOY_PATH"

for file in "${FILES_TO_DEPLOY[@]}"; do
    if [[ -f "$file" ]]; then
        log_info "Uploading $file..."
        if scp $SSH_OPTS "$file" "$VM_USER@$VM_IP:$DEPLOY_PATH/"; then
            log_success "Deployed $file"

            # Set proper permissions
            ssh $SSH_OPPS "$VM_USER@$VM_IP" "chmod 644 $DEPLOY_PATH/$file" || {
                log_warning "Could not set permissions for $file"
            }
        else
            log_error "Failed to deploy $file"
            exit 1
        fi
    else
        log_warning "File not found: $file (skipping)"
    fi
done

# Set proper ownership (try with sudo, fallback without)
log_info "Setting permissions on remote directory..."
ssh $SSH_OPTS "$VM_USER@$VM_IP" "sudo chown -R www-data:www-data $DEPLOY_PATH 2>/dev/null || chown -R $VM_USER:$VM_USER $DEPLOY_PATH" || {
    log_warning "Could not set ownership (may need manual adjustment)"
}

# Optionally restart Apache (commented out by default)
# Uncomment if you need Apache to reload
# log_info "Restarting Apache..."
# ssh $SSH_OPTS "$VM_USER@$VM_IP" "sudo systemctl reload apache2 || sudo systemctl reload httpd" || {
#     log_warning "Could not restart Apache (may need manual restart)"
# }

log_success "Deployment completed successfully! ✓"
log_info "Your site should be available at: http://$VM_IP"
log_info "PHP status page: http://$VM_IP/app.php"
