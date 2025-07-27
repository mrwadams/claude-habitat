#!/bin/bash
# Claude Habitat Setup Script
# Detects and installs Docker using the most appropriate method for the system

set -e

echo "🌿 Claude Habitat Setup"
echo "======================="

# Function to check if Docker is installed
check_docker() {
    if command -v docker &> /dev/null; then
        echo "✅ Docker is already installed"
        docker --version
        return 0
    else
        return 1
    fi
}

# Function to check if Docker Compose is installed
check_docker_compose() {
    if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
        echo "✅ Docker Compose is already installed"
        return 0
    else
        return 1
    fi
}

# Install Docker on Ubuntu/Debian
install_docker_apt() {
    echo "📦 Installing Docker using apt..."
    
    # Update package index
    sudo apt-get update
    
    # Install prerequisites
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Set up the repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker Engine
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    
    echo "✅ Docker installed successfully via apt"
    echo "⚠️  Please log out and back in for group changes to take effect"
}

# Install Docker using snap (fallback for Digital Ocean and some Ubuntu versions)
install_docker_snap() {
    echo "📦 Installing Docker using snap..."
    sudo snap install docker
    
    # Add current user to docker group
    sudo addgroup --system docker
    sudo adduser $USER docker
    sudo snap disable docker
    sudo snap enable docker
    
    echo "✅ Docker installed successfully via snap"
    echo "⚠️  Please log out and back in for group changes to take effect"
}

# Main installation logic
main() {
    # Check if Docker is already installed
    if check_docker; then
        if check_docker_compose; then
            echo "🎉 All requirements are already installed!"
            echo ""
            echo "You can now run:"
            echo "  cd claude-habitat"
            echo "  docker compose up -d"
            return 0
        fi
    fi
    
    # Detect OS
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        echo "❌ Cannot detect OS. Please install Docker manually."
        exit 1
    fi
    
    # Install based on OS
    case $OS in
        ubuntu|debian)
            # Try apt method first
            if install_docker_apt; then
                echo "✅ Installation complete!"
            else
                echo "⚠️  apt installation failed, trying snap..."
                install_docker_snap
            fi
            ;;
        *)
            echo "❌ Unsupported OS: $OS"
            echo "Please install Docker manually from: https://docs.docker.com/get-docker/"
            exit 1
            ;;
    esac
    
    echo ""
    echo "🎉 Setup complete!"
    echo ""
    echo "Next steps:"
    echo "1. Log out and back in (required for Docker group permissions)"
    echo "2. Clone the repository if you haven't:"
    echo "   git clone https://github.com/mrwadams/claude-habitat.git"
    echo "3. Start Claude Habitat:"
    echo "   cd claude-habitat"
    echo "   docker compose up -d"
}

# Run main function
main