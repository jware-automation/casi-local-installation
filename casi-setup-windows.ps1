# Function to install Docker on Windows
function Install-DockerWindows {
  # Check if Docker is already installed
  if (Test-Path -Path "C:\Program Files\Docker\Docker\docker.exe") {
    Write-Output "Docker is already installed."
    & "C:\Program Files\Docker\Docker\docker.exe" --version
  }
  else {
    Write-Output "Docker is not installed. Installing Docker..."
    # Download Docker Desktop installer
    Invoke-WebRequest -Uri 'https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe' -OutFile 'DockerDesktopInstaller.exe'

    # Execute the Docker Desktop installer silently
    Start-Process -Wait -FilePath .\DockerDesktopInstaller.exe -ArgumentList '/quiet'

    # Remove the installer file
    Remove-Item -Path .\DockerDesktopInstaller.exe

    # Display Docker version
    docker --version
  }
}
function Setup-Casi-System {
  # Array of image names and tags
  $image_name="janithjware/casi-container"
  $network="casi-network"

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

# Get the operating system type
$OS = $env:OS

# Determine the operating system and install Docker accordingly
if ($OS -eq 'Linux') {
  # Installation for Linux distributions
  Write-Output "Linux installation not supported through this script."
  exit 1
}
elseif ($OS -eq 'Darwin') {
  # Installation for macOS
  Write-Output "macOS installation not supported through this script."
  exit 1
}
elseif ($OS -eq 'Windows_NT') {
  # Installation for Windows
  Install-DockerWindows
  Setup-Casi-System
}
else {
  Write-Output "Unsupported operating system: $OS"
  exit 1
}
