#!/bin/bash
set -e

echo "==> Configuration de l'utilisateur vagrant..."

# Création du répertoire .ssh pour vagrant
mkdir -p /home/vagrant/.ssh
chmod 0700 /home/vagrant/.ssh

# Téléchargement et installation de la clé publique Vagrant
curl -fsSL https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -o /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# Configuration SSH
echo "==> Configuration SSH..."
sed -i "s/#UseDNS yes/UseDNS no/" /etc/ssh/sshd_config
sed -i "s/GSSAPIAuthentication yes/GSSAPIAuthentication no/" /etc/ssh/sshd_config

# Vérification que vagrant est dans le groupe wheel
usermod -a -G wheel vagrant

echo "==> Configuration Vagrant terminée"