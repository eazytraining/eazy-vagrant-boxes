packer {
  required_plugins {
    virtualbox = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

source "virtualbox-iso" "centos" {
  vm_name       = "centos-stream-9-simple"
  guest_os_type = "RedHat_64"
  
  # ISO Configuration
  iso_urls = [
    "CentOS-Stream-9-20250728.1-x86_64-dvd1.iso",
    "https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-20250728.1-x86_64-dvd1.iso"
  ]
  iso_checksum = "sha256:b64ed51b9af257085741ce065e7abc3d846b4aff349e75f17d7b304f44baf523"
  
  # Hardware
  memory    = 2048
  cpus      = 2
  disk_size = 20480
  
  # SSH Configuration - Paramètres étendus pour debug
  ssh_username             = "vagrant"
  ssh_password             = "vagrant"
  ssh_timeout              = "60m"
  ssh_handshake_attempts   = 50
  ssh_wait_timeout         = "60m"
  
  # VirtualBox specific
  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--memory", "2048"],
    ["modifyvm", "{{.Name}}", "--cpus", "2"],
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
    ["modifyvm", "{{.Name}}", "--uart1", "0x3F8", "4"],
    ["modifyvm", "{{.Name}}", "--uartmode1", "file", "{{.Name}}-console.log"]
  ]
  
  # Mode debug - garde la fenêtre VirtualBox ouverte
  headless = false
  
  # Boot configuration
  boot_wait = "15s"
  boot_command = [
    "<tab> text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos-ks-simple.cfg console=tty0 console=ttyS0,115200n8<enter><wait>"
  ]
  
  # HTTP server pour le kickstart
  http_directory = "http"
  
  # Shutdown
  shutdown_command = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
}

build {
  sources = ["source.virtualbox-iso.centos"]
  
  # Test de base pour vérifier la connectivité
  provisioner "shell" {
    inline = [
      "echo 'SSH connection successful!'",
      "echo 'Current user:' $(whoami)",
      "echo 'System info:' $(uname -a)", 
      "echo 'Network config:'",
      "ip addr show",
      "echo 'SSH service status:'",
      "sudo systemctl status sshd"
    ]
  }
  
  # Post-processor pour créer la box
  post-processor "vagrant" {
    output = "builds/centos-stream-9-simple-{{.Provider}}.box"
  }
}