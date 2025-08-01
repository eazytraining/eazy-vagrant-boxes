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

source "virtualbox-iso" "ubuntu" {
  boot_command = [
    "<esc><wait>",
    "c<wait>",
    "set gfxpayload=keep<wait><enter>",
    "linux /casper/vmlinuz autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait><enter>",
    "initrd /casper/initrd<wait><enter>",
    "boot<wait><enter>"
  ]

  boot_wait      = "10s"
  disk_size      = "20480"
  guest_os_type  = "Ubuntu_64"
  headless       = true
  http_directory = "http"

  iso_urls = [
    "ubuntu-22.04.5-live-server-amd64.iso",
    "https://releases.ubuntu.com/jammy/ubuntu-22.04.5-live-server-amd64.iso"
  ]

  iso_checksum            = "sha256:9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"
  ssh_username            = "vagrant"
  ssh_password            = "vagrant"
  ssh_port                = 22
  ssh_wait_timeout        = "3600s"
  shutdown_command        = "echo 'vagrant'|sudo -S shutdown -P now"
  guest_additions_path    = "VBoxGuestAdditions_{{.Version}}.iso"
  guest_additions_mode    = "upload"
  guest_additions_sha256  = ""
  virtualbox_version_file = ".vbox_version"
  vm_name                 = "packer-ubuntu-22.04-amd64"

  vboxmanage = [
    [
      "modifyvm",
      "{{.Name}}",
      "--memory",
      "6144"
    ],
    [
      "modifyvm",
      "{{.Name}}",
      "--cpus",
      "4"
    ]
  ]
}

build {
  sources = ["source.virtualbox-iso.ubuntu"]

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    script          = "scripts/virtualbox.sh"
  }

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    script          = "scripts/setup.sh"
  }

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    script          = "scripts/cleanup.sh"
  }

  provisioner "file" {
    source      = "./motd"
    destination = "/tmp/motd"
  }

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E bash -c '{{.Path}}'"
    inline          = ["sudo mv /tmp/motd /etc/motd"]
  }

  post-processors {
    post-processor "vagrant" {
      output = "builds/{{.Provider}}-ubuntu2204.box"
    }
  }
}