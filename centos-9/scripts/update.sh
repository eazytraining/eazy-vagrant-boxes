#!/bin/bash
set -e

echo "==> Mise à jour du système..."

# Mise à jour de tous les packages
dnf update -y

# Installation des outils de développement nécessaires
dnf groupinstall -y "Development Tools"
dnf install -y kernel-devel kernel-headers dkms gcc make perl bzip2

echo "==> Mise à jour terminée"