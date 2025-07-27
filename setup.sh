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
    echo "🎉 Docker setup complete!"
    echo ""
    
    # Clone and start Claude Habitat
    echo "📥 Cloning Claude Habitat repository..."
    if [ -d "claude-habitat" ]; then
        echo "⚠️  claude-habitat directory already exists. Updating..."
        cd claude-habitat
        git pull
    else
        git clone https://github.com/mrwadams/claude-habitat.git
        cd claude-habitat
    fi
    
    echo ""
    echo "🚀 Starting Claude Habitat..."
    
    # Check if we can run docker commands
    if docker info &> /dev/null; then
        # Initialize directories with proper permissions
        ./init.sh
        docker compose up -d
        
        echo ""
        echo "✨ Claude Habitat is starting!"
        echo ""
        
        # Wait a moment for code-server to generate its config
        echo "Waiting for code-server to initialize..."
        sleep 10
        
        # Try to get the password from inside the container
        PASSWORD=$(docker exec claude-habitat cat /home/coder/.config/code-server/config.yaml 2>/dev/null | grep "^password:" | cut -d' ' -f2)
        if [ -n "$PASSWORD" ]; then
            echo "🔑 Code-server password: $PASSWORD"
            echo ""
        fi
        
        echo "📍 Access your environment at: http://$(hostname -I | awk '{print $1}'):8080"
        echo "   Or if running locally: http://localhost:8080"
        echo ""
        echo "To check status: docker compose ps"
        echo "To view logs: docker compose logs -f"
        echo "To stop: docker compose down"
    else
        echo ""
        echo "⚠️  Cannot start containers yet. Please log out and back in first (required for Docker permissions)."
        echo ""
        echo "After logging back in, start Claude Habitat with:"
        echo "  cd claude-habitat"
        echo "  docker compose up -d"
    fi
}

# Run main function
main