# Define required Terraform providers
provider "local" {}  # Used to execute local scripts
provider "null" {}   # Allows execution of custom scripts via local-exec



# Write the install script to a file
resource "local_file" "install_minikube_script" {
  filename = "${path.module}/install_minikube.ps1"
  content  = <<EOT
if (-Not (Get-Command minikube -ErrorAction SilentlyContinue)) {
    Write-Output "Installing Minikube..."
    Invoke-WebRequest -Uri "https://storage.googleapis.com/minikube/releases/latest/minikube-windows-amd64.exe" -OutFile "C:\\Program Files\\minikube\\minikube.exe"
    [System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\\Program Files\\minikube", "Machine")
    Write-Output "Minikube installation completed."
} else {
    Write-Output "Minikube is already installed."
}
EOT
}

# Execute the install script
resource "null_resource" "install_minikube" {
  depends_on = [local_file.install_minikube_script]

  provisioner "local-exec" {
    command = "powershell -ExecutionPolicy Bypass -NoProfile -File ${path.module}/install_minikube.ps1"
  }
}

# Write the start script to a file
resource "local_file" "start_minikube_script" {
  filename = "${path.module}/start_minikube.ps1"
  content  = <<EOT
Write-Output "Starting Minikube with Docker driver and profile gitops-pro..."
minikube start --driver=docker --profile=gitops-pro
Write-Output "Minikube started successfully with profile gitops-pro!"
EOT
}

# Execute the start script
resource "null_resource" "start_minikube" {
  depends_on = [null_resource.install_minikube]

  provisioner "local-exec" {
    command = "powershell -ExecutionPolicy Bypass -NoProfile -File ${path.module}/start_minikube.ps1"
  }
}




# Output message indicating successful Minikube setup
output "minikube_status" {
  value = "Minikube has been successfully installed and started with the profile 'gitops-pro'!"
}
