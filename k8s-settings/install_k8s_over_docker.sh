#!/bin/bash

# k8s-native-mac-minimal.sh
# Minimal Native Kubernetes Setup on macOS with Docker Desktop

set -e

echo "🚀 Starting minimal Kubernetes setup on macOS..."
echo "=================================================="

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

if [[ "$(uname)" != "Darwin" ]]; then
    print_error "This script is designed for macOS only!"
    exit 1
fi

command_exists() {
    command -v "$1" &> /dev/null
}

install_homebrew() {
    if ! command_exists brew; then
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        if [[ -x /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -x /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        print_info "Homebrew is already installed"
    fi
}

install_docker_desktop() {
    if ! command_exists docker; then
        print_info "Docker not found. Please install Docker Desktop manually:"
        print_info "1. Download from: https://www.docker.com/products/docker-desktop/"
        print_info "2. Install and open Docker Desktop"
        print_info "3. Enable Kubernetes in Docker Desktop settings"
        print_info "4. Restart Docker Desktop"
        print_info "Press Enter after Docker Desktop is installed and configured..."
        read -r
    else
        print_info "Docker is already installed"
    fi
}

configure_docker_kubernetes() {
    print_info "Checking Docker Desktop Kubernetes configuration..."
    
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker Desktop."
        exit 1
    fi
    
    if ! kubectl config get-contexts | grep -q "docker-desktop"; then
        print_warning "Kubernetes is not enabled in Docker Desktop"
        print_info "Please enable Kubernetes in Docker Desktop:"
        print_info "1. Open Docker Desktop"
        print_info "2. Go to Settings → Kubernetes"
        print_info "3. Check 'Enable Kubernetes'"
        print_info "4. Click 'Apply & Restart'"
        print_info "5. Wait for Kubernetes to start (this may take several minutes)"
        print_info "Press Enter after Kubernetes is enabled..."
        read -r
    fi
}

install_kubectl() {
    if ! command_exists kubectl; then
        print_info "Installing kubectl..."
        brew install kubectl
    else
        print_info "kubectl is already installed"
    fi
}

setup_kubeconfig() {
    print_info "Setting up kubeconfig..."
    kubectl config use-context docker-desktop
    
    
    if kubectl cluster-info &> /dev/null; then
        print_success "Successfully connected to Kubernetes cluster"
    else
        print_error "Failed to connect to Kubernetes cluster"
        print_info "Make sure Docker Desktop is running and Kubernetes is enabled"
        exit 1
    fi
}

check_cluster_status() {
    print_info "Checking cluster status..."
    
    sleep 10
    
    print_info "Kubernetes nodes:"
    kubectl get nodes -o wide
    
    print_info "System pods:"
    kubectl get pods -A --field-selector=status.phase=Running
    
    print_info "Cluster info:"
    kubectl cluster-info
}

main() {
    print_info "Starting minimal Kubernetes setup"
    
    install_homebrew
    install_docker_desktop
    install_kubectl
    configure_docker_kubernetes
    setup_kubeconfig
    check_cluster_status
    
    print_success "✅ Minimal Kubernetes cluster is ready!"
    print_success "Container Runtime: Docker"
    print_success "Kubernetes version: $(kubectl version --short 2>/dev/null | grep 'Server' | awk '{print $3}')"
    
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
