if (-Not (Get-Command minikube -ErrorAction SilentlyContinue)) {
    Write-Output "Installing Minikube..."
    Invoke-WebRequest -Uri "https://storage.googleapis.com/minikube/releases/latest/minikube-windows-amd64.exe" -OutFile "C:\\Program Files\\minikube\\minikube.exe"
    [System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\\Program Files\\minikube", "Machine")
    Write-Output "Minikube installation completed."
} else {
    Write-Output "Minikube is already installed."
}
