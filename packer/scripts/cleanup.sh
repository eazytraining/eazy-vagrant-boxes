#!/bin/bash -eux
# packer/scripts/cleanup.sh

echo "=== Début du nettoyage final ==="

# Nettoyage des paquets
apt-get autoremove -y
apt-get autoclean
apt-get clean

# Nettoyage des caches
rm -rf /var/cache/apt/archives/*.deb
rm -rf /var/cache/apt/archives/partial/*.deb
rm -rf /var/cache/apt/*.bin

# Nettoyage des logs
find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;
find /var/log -type f -name "*.1" -delete
find /var/log -type f -name "*.gz" -delete
truncate -s 0 /var/log/wtmp
truncate -s 0 /var/log/lastlog

# Nettoyage de l'historique
history -c
cat /dev/null > ~/.bash_history
rm -f /home/vagrant/.bash_history
rm -f /root/.bash_history

# Nettoyage des fichiers temporaires
rm -rf /tmp/*
rm -rf /var/tmp/*

# Nettoyage SSH
rm -f /etc/ssh/ssh_host_*
rm -f /home/vagrant/.ssh/known_hosts

# Nettoyage des certificats machine
rm -f /etc/ssl/certs/ssl-cert-snakeoil.pem
rm -f /etc/ssl/private/ssl-cert-snakeoil.key

# Nettoyage udev
rm -f /etc/udev/rules.d/70-persistent-net.rules

# Nettoyage des IDs uniques
if [ -f /etc/machine-id ]; then
    truncate -s 0 /etc/machine-id
fi

if [ -f /var/lib/dbus/machine-id ]; then
    rm -f /var/lib/dbus/machine-id
    ln -s /etc/machine-id /var/lib/dbus/machine-id
fi

# Nettoyage network
rm -f /etc/netplan/50-cloud-init.yaml

# Vider les fichiers swap
swapoff -a
if [ -f /swapfile ]; then
    dd if=/dev/zero of=/swapfile bs=1M || true
    rm -f /swapfile
fi

# Remplissage de l'espace libre avec des zéros (pour compression)
dd if=/dev/zero of=/EMPTY bs=1M || true
rm -f /EMPTY

# Synchronisation finale
sync

echo "=== Nettoyage final terminé ==="