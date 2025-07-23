# ubuntu22.pkr.hcl
packer {
  required_plugins {
    virtualbox = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/virtualbox"
    }
    vagrant = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vagrant"
    }
    ansible = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

# Ubuntu 22.04 LTS Cloud Image
source "virtualbox-iso" "ubuntu2204" {
  # Ubuntu 22.04 LTS Cloud Image (beaucoup plus léger)
  iso_urls = [
    "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
  ]
  iso_checksum = "file:https://cloud-images.ubuntu.com/releases/22.04/release/SHA256SUMS"
  
  # Configuration VM
  guest_os_type    = "Ubuntu_64"
  vm_name          = "packer-${var.box_name}"
  cpus             = var.cpus
  memory           = var.memory
  disk_size        = var.disk_size
  headless         = var.headless
  
  # Configuration réseau et SSH
  ssh_username     = var.ssh_username
  ssh_password     = var.ssh_password
  ssh_timeout      = "30m"
  ssh_port         = 22
  
  # Configuration cloud-init
  http_directory   = "http"
  boot_wait        = "5s"
  boot_command = [
    # Cloud-init utilise une approche différente
    "<enter><wait><f6><esc><wait>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs>",
    "/install/vmlinuz ",
    "initrd=/install/initrd.gz ",
    "auto-install/enable=true ",
    "debconf/priority=critical ",
    "preseed/url=http://{{.HTTPIP}}:{{.HTTPPort}}/user-data ",
    "<enter>"
  ]
  
  # Configuration VirtualBox spécifique
  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
    ["modifyvm", "{{.Name}}", "--memory", "${var.memory}"],
    ["modifyvm", "{{.Name}}", "--cpus", "${var.cpus}"],
    ["modifyvm", "{{.Name}}", "--vram", "16"],
    ["modifyvm", "{{.Name}}", "--rtcuseutc", "on"],
    ["modifyvm", "{{.Name}}", "--accelerate3d", "off"],
    ["modifyvm", "{{.Name}}", "--clipboard-mode", "bidirectional"],
    ["modifyvm", "{{.Name}}", "--draganddrop", "bidirectional"]
  ]
  
  # Commande d'arrêt
  shutdown_command = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  
  # Configuration des additions invité
  guest_additions_mode = "upload"
  guest_additions_path = "VBoxGuestAdditions_{{.Version}}.iso"
  virtualbox_version_file = ".vbox_version"
}

# Configuration du build
build {
  name    = "ubuntu2204"
  sources = ["source.virtualbox-iso.ubuntu2204"]

  # Installation d'Ansible
  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    script          = "scripts/ansible.sh"
  }

  # Configuration système de base
  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    script          = "scripts/setup.sh"
  }

  # Provisioning Ansible
  provisioner "ansible-local" {
    playbook_file   = "../ansible/main.yml"
    galaxy_file     = "../ansible/requirements.yml"
    extra_arguments = [
      "--vault-password-file=/tmp/vault_pass"
    ]
  }

  # Nettoyage final
  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    script          = "scripts/cleanup.sh"
  }

  # Post-processing : création de la box Vagrant
  post-processor "vagrant" {
    output = "builds/{{.Provider}}-${var.box_name}-${var.version}.box"
  }

  # Post-processing : publication sur Vagrant Cloud
  post-processor "vagrant-cloud" {
    box_tag             = "${var.vagrant_cloud_username}/${var.box_name}"
    version             = var.version
    version_description = "Ubuntu 22.04 LTS with Ansible and Docker"
    access_token        = var.vagrant_cloud_token
    no_release          = false
  }
}