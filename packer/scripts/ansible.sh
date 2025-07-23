#!/bin/bash -eux
# packer/scripts/ansible.sh

# Mise à jour des paquets
apt-get update

# Installation de Python et pip
apt-get install -y python3 python3-pip python3-dev

# Installation d'Ansible via pip
pip3 install --upgrade pip
pip3 install ansible

# Vérification de l'installation
ansible --version

# Installation de collections Ansible utiles
ansible-galaxy collection install community.general
ansible-galaxy collection install ansible.posix

# Création du répertoire pour les playbooks
mkdir -p /tmp/ansible

echo "Ansible installation completed successfully"