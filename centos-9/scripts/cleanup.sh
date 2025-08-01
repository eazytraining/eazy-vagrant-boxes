#!/bin/bash
set -e

echo "==> Nettoyage du système..."

# Nettoyage des packages
dnf clean all
dnf autoremove -y

# Nettoyage des logs
find /var/log -type f -exec truncate -s 0 {} \;

# Nettoyage de l'historique bash
history -c
> /home/vagrant/.bash_history
> /root/.bash_history

# Nettoyage des fichiers temporaires
rm -rf /tmp/*
rm -rf /var/tmp/*

# Nettoyage du cache
rm -rf /var/cache/dnf/*

# Nettoyage des fichiers de réseau
rm -f /etc/udev/rules.d/70-persistent-net.rules

# Suppression des clés SSH de l'hôte (seront régénérées au boot)
rm -f /etc/ssh/ssh_host_*

# Vidage de l'espace libre pour réduire la taille de l'image
dd if=/dev/zero of=/EMPTY bs=1M || true
rm -f /EMPTY

# Synchronisation
sync

echo "==> Nettoyage terminé"