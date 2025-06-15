#!/bin/bash

# ==========================================
# ASCII Art Banner
# ==========================================
echo '

██████╗ ███████╗██╗   ██╗███████╗██╗     ███████╗██████╗ ███╗   ███╗███████╗███╗   ██╗████████╗
██╔══██╗██╔════╝██║   ██║██╔════╝██║     ██╔══██║██╔══██╗████╗ ████║██╔════╝████╗  ██║╚══██╔══╝
██║  ██║█████╗  ██║   ██║█████╗  ██║     ██║  ██║██████╔╝██╔████╔██║█████╗  ██╔██╗ ██║   ██║   
██║  ██║██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║     ██║  ██║██╔═══╝ ██║╚██╔╝██║██╔══╝  ██║╚██╗██║   ██║   
██████╔╝███████╗ ╚████╔╝ ███████╗███████╗███████║██║     ██║ ╚═╝ ██║███████╗██║ ╚████║   ██║   
╚═════╝ ╚══════╝  ╚═══╝  ╚══════╝╚══════╝╚══════╝╚═╝     ╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝   

████████╗███████╗███████╗██╗     
╚══██╔══╝██╔══██║██╔══██║██║     
   ██║   ██║  ██║██║  ██║██║     
   ██║   ██║  ██║██║  ██║██║     
   ██║   ███████║███████║███████╗
   ╚═╝   ╚══════╝╚══════╝╚══════╝
'

# ==========================================
# Sudo Verification
# ==========================================
if ! command -v sudo &> /dev/null; then
    echo "Error: sudo is not installed. Please install sudo first."
    exit 1
fi

# Check if user has sudo privileges
if ! sudo -v &> /dev/null; then
    echo "Error: User does not have sudo privileges."
    echo "Please ensure you have sudo access before running this script."
    exit 1
fi

# Cleanup function
cleanup() {
    local exit_code=$?
    local current_dir=$(pwd)
    
    # Restore the original directory
    cd "$current_dir"
    
    # Print a newline for better formatting
    echo
    
    # Exit with the original exit code
    exit $exit_code
}

# Set up trap to clean up on script exit
trap cleanup EXIT

# ==========================================
# Development Environment Setup Script
# ==========================================

# Function to print section headers
print_section() {
    echo -e "\n=========================================="
    echo "🔧 $1"
    echo "=========================================="
}

# Function to check version and print status
check_version() {
    local tool_name=$1
    local installed_version=$2
    local latest_version=$3
    local update_command=$4

    echo "📦 $tool_name: $installed_version"
    
    if [ -z "$latest_version" ]; then
        return
    fi

    if [ "$installed_version" != "$latest_version" ]; then
        echo "🔄 Update available: $latest_version"
        echo "   Run: $update_command"
    else
        echo "✅ Up to date"
    fi
}

# Function to get latest Git version from GitHub API
get_latest_git_version() {
    # Get the latest stable version (first non-rc tag)
    local latest_version=$(curl -s https://api.github.com/repos/git/git/tags | grep -o '"name":"v[0-9]*\.[0-9]*\.[0-9]*"' | head -n 1 | cut -d'"' -f4 | cut -c 2-)
    echo "$latest_version"
}

# Function to get latest DBeaver version
get_latest_dbeaver_version() {
    # Get the latest version from DBeaver's GitHub releases
    local latest_version=$(curl -s https://api.github.com/repos/dbeaver/dbeaver/releases/latest | grep -o '"tag_name":"[^"]*' | cut -d'"' -f4 | cut -c 2-)
    echo "$latest_version"
}

# Function to get latest Postman version
get_latest_postman_version() {
    # Get the latest version from Postman's GitHub releases
    local latest_version=$(curl -s https://api.github.com/repos/postmanlabs/postman-app-support/releases/latest | grep -o '"tag_name":"[^"]*' | cut -d'"' -f4 | cut -c 2-)
    echo "$latest_version"
}

# Function to install NVM and Node.js
install_nodejs() {
    if [ ! -d "$HOME/.nvm" ]; then
        echo "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        
        # Add NVM to current shell session
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        
        # Add to shell config for future sessions
        {
            echo 'export NVM_DIR="$HOME/.nvm"'
            echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
            echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'
        } >> ~/.bashrc

        # Source bashrc to make NVM available in current session
        source ~/.bashrc
    else
        # If NVM exists but isn't initialized in current session
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    fi

    # Verify NVM is available
    if ! command -v nvm &> /dev/null; then
        echo "Error: NVM installation failed or is not properly initialized"
        return 1
    fi

    # Get latest LTS version
    LATEST_NODE_VERSION=$(nvm ls-remote --lts | tail -n 1 | grep -o 'v[0-9]*\.[0-9]*\.[0-9]*' | cut -c 2-)
    
    echo "Installing Node.js LTS version..."
    nvm install --lts

    INSTALLED_NODE_VERSION=$(node --version | cut -c 2-)
    check_version "Node.js" "$INSTALLED_NODE_VERSION" "$LATEST_NODE_VERSION" "nvm install --lts"
}

# Function to install SDKMAN and Java versions
install_java() {
    if [ ! -d "$HOME/.sdkman" ]; then
        echo "Installing SDKMAN..."
        curl -s "https://get.sdkman.io" | bash
        
        # Add SDKMAN to current shell session
        export SDKMAN_DIR="$HOME/.sdkman"
        [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
        
        # Add to shell config for future sessions
        {
            echo 'export SDKMAN_DIR="$HOME/.sdkman"'
            echo '[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"'
        } >> ~/.bashrc

        # Source bashrc to make SDKMAN available in current session
        source ~/.bashrc
    else
        # If SDKMAN exists but isn't initialized in current session
        export SDKMAN_DIR="$HOME/.sdkman"
        [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
    fi

    # Verify SDKMAN is available
    if ! command -v sdk &> /dev/null; then
        echo "Error: SDKMAN installation failed or is not properly initialized"
        return 1
    fi

    # Install Java versions
    JAVA_VERSIONS=("8.0.392-amzn" "11.0.21-amzn" "17.0.9-amzn" "21.0.1-amzn")
    
    for version in "${JAVA_VERSIONS[@]}"; do
        echo "Installing Java $version..."
        sdk install java $version
    done

    # Show installed versions and current default
    echo "Installed Java versions:"
    sdk list java | grep installed
    
    # Show current default version
    CURRENT_DEFAULT=$(sdk current java | grep "Using java version" | cut -d' ' -f4)
    echo -e "\nCurrent default: $CURRENT_DEFAULT"
    echo "To change default version, use: sdk default java <version>"
    echo "Available versions:"
    for version in "${JAVA_VERSIONS[@]}"; do
        echo "  sdk default java $version"
    done
}

# Function to install pyenv and Python
install_python() {
    print_section "Python Setup"
    
    # Check if Python is already installed via pyenv
    if [ -d "$HOME/.pyenv" ]; then
        # Initialize pyenv in current session if not already initialized
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init --path)"
        eval "$(pyenv init -)"
        
        # Check if Python is installed via pyenv
        if pyenv versions | grep -q "^\*"; then
            INSTALLED_PYTHON_VERSION=$(pyenv version | cut -d' ' -f1)
            echo "📦 Python: $INSTALLED_PYTHON_VERSION (via pyenv)"
            return
        fi
    fi

    # Install dependencies first
    echo "Installing Python dependencies..."
    sudo apt-get update
    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

    if [ ! -d "$HOME/.pyenv" ]; then
        echo "Installing pyenv..."
        curl https://pyenv.run | bash
        
        # Add pyenv to current shell session
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        
        # Initialize pyenv in current shell
        eval "$(pyenv init --path)"
        eval "$(pyenv init -)"
        
        # Add to shell config for future sessions
        {
            echo 'export PYENV_ROOT="$HOME/.pyenv"'
            echo 'export PATH="$PYENV_ROOT/bin:$PATH"'
            echo 'eval "$(pyenv init --path)"'
            echo 'eval "$(pyenv init -)"'
        } >> ~/.bashrc

        # Source bashrc to make pyenv available in current session
        source ~/.bashrc
    else
        # If pyenv exists but isn't initialized in current session
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init --path)"
        eval "$(pyenv init -)"
    fi

    # Verify pyenv is available
    if ! command -v pyenv &> /dev/null; then
        echo "Error: pyenv installation failed or is not properly initialized"
        return 1
    fi

    # Get latest Python version
    LATEST_PYTHON_VERSION=$(pyenv install --list | grep -v - | grep -v b | tail -n 1 | tr -d ' ')
    
    echo "Installing Python $LATEST_PYTHON_VERSION..."
    pyenv install $LATEST_PYTHON_VERSION

    # Set the installed version as the current version
    pyenv global $LATEST_PYTHON_VERSION

    # Verify installation and get version
    INSTALLED_PYTHON_VERSION=$(pyenv version | cut -d' ' -f1)
    check_version "Python" "$INSTALLED_PYTHON_VERSION" "$LATEST_PYTHON_VERSION" "pyenv install $LATEST_PYTHON_VERSION"
}

# ==========================================
# Docker Installation
# ==========================================
print_section "Docker Setup"

# Add user to docker group first
if ! groups | grep -q docker; then
    echo "Adding user to docker group..."
    sudo usermod -aG docker $USER
    
    echo -e "\n⚠️  Group changes require a new session to take effect."
    echo "You have two options:"
    echo "1. Log out and log back in (recommended)"
    echo "2. Run this command in your current session:"
    echo "   newgrp docker"
    echo -e "\nThe script will continue, but Docker commands may not work until you complete one of these steps."
    echo "Press Enter to continue..."
    read
fi

# Check if Docker is already installed
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | tr -d ',')
    DOCKER_COMPOSE_VERSION=$(docker compose version --short)
    check_version "Docker" "$DOCKER_VERSION" "" ""
    check_version "Docker Compose" "$DOCKER_COMPOSE_VERSION" "" ""
else
    # Install Docker
    echo "Installing Docker..."
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Add Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update package index
    apt-get update

    # Install Docker packages
    apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin

    # Verify Docker installation
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | tr -d ',')
    DOCKER_COMPOSE_VERSION=$(docker compose version --short)
    check_version "Docker" "$DOCKER_VERSION" "" ""
    check_version "Docker Compose" "$DOCKER_COMPOSE_VERSION" "" ""
fi

# ==========================================
# Node.js Installation
# ==========================================
print_section "Node.js Setup"
install_nodejs

# ==========================================
# Java Installation
# ==========================================
print_section "Java Setup"
install_java

# ==========================================
# Python Installation
# ==========================================
install_python

# ==========================================
# IntelliJ IDEA Installation
# ==========================================
print_section "IntelliJ IDEA Setup"

# Get latest version from JetBrains website
LATEST_VERSION=$(curl -s "https://data.services.jetbrains.com/products/releases?code=IIC&latest=true&type=release" | grep -o '"version":"[^"]*' | cut -d'"' -f4)

if snap list | grep -q "intellij-idea-community"; then
    INSTALLED_VERSION=$(snap list intellij-idea-community | awk 'NR==2 {print $2}' | cut -d'-' -f1)
    check_version "IntelliJ IDEA" "$INSTALLED_VERSION" "$LATEST_VERSION" "sudo snap refresh intellij-idea-community"
else
    echo "Installing IntelliJ IDEA Community Edition..."
    sudo snap install intellij-idea-community --classic
    INSTALLED_VERSION=$(snap list intellij-idea-community | awk 'NR==2 {print $2}' | cut -d'-' -f1)
    check_version "IntelliJ IDEA" "$INSTALLED_VERSION" "$LATEST_VERSION" "sudo snap refresh intellij-idea-community"
fi

# ==========================================
# Visual Studio Code Installation
# ==========================================
print_section "Visual Studio Code Setup"

# Get latest version from VS Code API
LATEST_VSCODE_VERSION=$(curl -s https://api.github.com/repos/microsoft/vscode/releases/latest | grep -o '"tag_name":"[^"]*' | cut -d'"' -f4 | cut -c 2-)

if snap list | grep -q "code"; then
    INSTALLED_VSCODE_VERSION=$(snap list code | awk 'NR==2 {print $2}')
    check_version "VS Code" "$INSTALLED_VSCODE_VERSION" "$LATEST_VSCODE_VERSION" "sudo snap refresh code"
else
    echo "Installing Visual Studio Code..."
    sudo snap install code --classic
    INSTALLED_VSCODE_VERSION=$(snap list code | awk 'NR==2 {print $2}')
    check_version "VS Code" "$INSTALLED_VSCODE_VERSION" "$LATEST_VSCODE_VERSION" "sudo snap refresh code"
fi

# ==========================================
# Git Installation
# ==========================================
print_section "Git Setup"

# Get latest Git version from GitHub API
LATEST_GIT_VERSION=$(get_latest_git_version)

if command -v git >/dev/null 2>&1; then
    INSTALLED_GIT_VERSION=$(git --version | cut -d' ' -f3)
    check_version "Git" "$INSTALLED_GIT_VERSION" "$LATEST_GIT_VERSION" "sudo apt update && sudo apt upgrade git"
else
    echo "Installing Git..."
    sudo apt update
    sudo apt install -y git
    INSTALLED_GIT_VERSION=$(git --version | cut -d' ' -f3)
    check_version "Git" "$INSTALLED_GIT_VERSION" "$LATEST_GIT_VERSION" "sudo apt update && sudo apt upgrade git"
fi

# ==========================================
# DBeaver Installation
# ==========================================
print_section "DBeaver Setup"

# Get latest DBeaver version
LATEST_DBEAVER_VERSION=$(get_latest_dbeaver_version)

if snap list | grep -q "dbeaver-ce"; then
    INSTALLED_DBEAVER_VERSION=$(snap list dbeaver-ce | awk 'NR==2 {print $2}')
    check_version "DBeaver" "$INSTALLED_DBEAVER_VERSION" "$LATEST_DBEAVER_VERSION" "sudo snap refresh dbeaver-ce"
else
    echo "Installing DBeaver Community Edition..."
    sudo snap install dbeaver-ce
    INSTALLED_DBEAVER_VERSION=$(snap list dbeaver-ce | awk 'NR==2 {print $2}')
    check_version "DBeaver" "$INSTALLED_DBEAVER_VERSION" "$LATEST_DBEAVER_VERSION" "sudo snap refresh dbeaver-ce"
fi

# ==========================================
# Postman Installation
# ==========================================
print_section "Postman Setup"

# Get latest version
LATEST_POSTMAN_VERSION=$(get_latest_postman_version)

if snap list | grep -q "postman"; then
    INSTALLED_POSTMAN_VERSION=$(snap list postman | awk 'NR==2 {print $2}')
    check_version "Postman" "$INSTALLED_POSTMAN_VERSION" "$LATEST_POSTMAN_VERSION" "sudo snap refresh postman"
else
    echo "Installing Postman..."
    sudo snap install postman
    INSTALLED_POSTMAN_VERSION=$(snap list postman | awk 'NR==2 {print $2}')
    check_version "Postman" "$INSTALLED_POSTMAN_VERSION" "$LATEST_POSTMAN_VERSION" "sudo snap refresh postman"
fi

# ==========================================
# Script Completion
# ==========================================
print_section "Setup Complete"

echo "✅ All development tools have been installed and configured"

# Function to add environment configurations
add_env_config() {
    local config_file=$1
    local config_content='
# Development Environment Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
'

    # Check if config file exists
    if [ -f "$HOME/$config_file" ]; then
        # Check if configuration already exists
        if ! grep -q "Development Environment Configuration" "$HOME/$config_file"; then
            echo "Adding environment configuration to $config_file..."
            echo "$config_content" >> "$HOME/$config_file"
            return 0
        else
            echo "Environment configuration already exists in $config_file"
            return 1
        fi
    fi
    return 1
}

# Function to source shell configuration
source_shell_config() {
    local config_file=$1
    if [ -f "$HOME/$config_file" ]; then
        echo "Sourcing $config_file..."
        source "$HOME/$config_file"
        return 0
    fi
    return 1
}

# ==========================================
# Script Completion
# ==========================================
print_section "Setup Complete"

echo "✅ All development tools have been installed and configured"

# Add and source environment configurations
echo -e "\n📝 Configuring shell environment..."

# Handle .bashrc
if add_env_config ".bashrc"; then
    if source_shell_config ".bashrc"; then
        echo "✅ .bashrc has been updated and sourced"
    else
        echo "⚠️  .bashrc has been updated but could not be sourced"
        echo "   Please run: source ~/.bashrc"
    fi
fi

# Handle .zshrc
if add_env_config ".zshrc"; then
    if source_shell_config ".zshrc"; then
        echo "✅ .zshrc has been updated and sourced"
    else
        echo "⚠️  .zshrc has been updated but could not be sourced"
        echo "   Please run: source ~/.zshrc"
    fi
fi

echo -e "\n🎉 Setup completed successfully!"
echo "   Your development environment is ready to use!"

echo -e "\n⚠️  Important: A system reboot is recommended to ensure all changes take effect properly."
echo "   This is especially important for:"
echo "   - Docker group membership"
echo "   - Environment variable changes"
echo "   - System-wide tool installations"
echo -e "\n   Please save your work and reboot your system when convenient."

