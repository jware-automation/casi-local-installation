#!/bin/bash

# Get the operating system type
OS=$(uname -s)

# Function to install Docker on Ubuntu
install_docker_ubuntu() {
  if command -v docker &> /dev/null; then
    echo "Docker is already installed."
    docker --version
  else
    echo "Docker is not installed. Installing Docker..."
    # Update the package index
    sudo apt update

    # Install required dependencies
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Add the Docker repository
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update the package index again
    sudo apt update

    # Install Docker
    sudo apt install -y docker-ce docker-ce-cli containerd.io

    # Add the current user to the docker group (optional)
    sudo usermod -aG docker $USER

    # Display Docker version
    docker --version
  fi
  
}

# Function to install Docker on macOS
install_docker_macos() {
  if command -v docker &> /dev/null; then
    echo "Docker is already installed."
    docker --version
  else
    echo "Docker is not installed. Installing Docker..."
    # Check if Homebrew is installed
    if ! command -v brew >/dev/null; then
      echo "Homebrew is required for installing Docker on macOS. Please install Homebrew (https://brew.sh/) and try again."
      exit 1
    fi

    # Install Docker using Homebrew
    brew install docker

    # Start Docker service
    open /Applications/Docker.app

    # Display Docker version
    docker --version
  fi
  
}

setup_casi_system() {
  # Array of image names and tags
  image_name="janithjware/casi-container"
  network="casi-network"

  #network
  docker network create casi-network

  #database
  docker pull mysql
  docker run --name casi-database --network "${network}" -p 3307:3306 -e MYSQL_ROOT_PASSWORD=root1234 -d mysql
  sleep 30
  docker exec -it casi-database mysql -proot1234 -e "CREATE DATABASE industrial_dashboard_db; CREATE DATABASE admin_dashboard_db; ALTER USER 'root' IDENTIFIED WITH mysql_native_password BY 'root1234'; flush privileges;"

  #cellular
  docker pull "${image_name}":cellular
  docker run --name casi-cellular --network "${network}" -p 9001:9001 -e DB_HOST=casi-database -d "${image_name}":cellular

  #backend
  docker pull "${image_name}":backend
  docker run --name casi-backend --network "${network}" -p 9000:9000 -e DB_HOST=casi-database -d "${image_name}":backend

  #frontend
  docker pull "${image_name}":frontend
  docker run --name casi-frontend -p 3000:3000 -d "${image_name}":frontend

}

# Determine the operating system and install Docker accordingly
if [[ "$OS" == "Linux" ]]; then
  if [[ -f /etc/os-release ]]; then
    # Source the os-release file to get the distribution information
    . /etc/os-release

    case "$ID" in
      ubuntu)
        install_docker_ubuntu
        setup_casi_system
        ;;
      *)
        echo "Unsupported Linux distribution: $ID"
        exit 1
        ;;
    esac
  else
    echo "Unsupported Linux distribution"
    exit 1
  fi
elif [[ "$OS" == "Darwin" ]]; then
  install_docker_macos
  setup_casi_system
else
  echo "Unsupported operating system: $OS"
  exit 1
fi
