#!/bin/bash -eux
# packer/scripts/setup.sh

echo "=== Début de la configuration système ==="

# Mise à jour complète du système
apt-get update
apt-get upgrade -y

# Installation des paquets essentiels
apt-get install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    tree \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    build-essential \
    dkms \
    linux-headers-$(uname -r)

# Configuration du fuseau horaire
timedatectl set-timezone UTC

# Configuration de l'utilisateur vagrant
usermod -aG sudo vagrant

# Configuration de SSH
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Installation de Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Ajout de l'utilisateur vagrant au groupe docker
usermod -aG docker vagrant

# Installation de Docker Compose (version standalone)
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Installation de Node.js et npm (via NodeSource)
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs

# Installation de quelques outils utiles
npm install -g yarn pm2

# Configuration de Vim avec quelques améliorations
cat > /home/vagrant/.vimrc << 'EOF'
set number
set expandtab
set tabstop=2
set shiftwidth=2
set autoindent
set smartindent
syntax on
set background=dark
EOF

chown vagrant:vagrant /home/vagrant/.vimrc

# Configuration de .bashrc pour vagrant
cat >> /home/vagrant/.bashrc << 'EOF'

# Alias utiles
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Variables d'environnement
export EDITOR=vim
export PATH=$PATH:/usr/local/bin

# Prompt coloré
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
EOF

# Redémarrage des services
systemctl restart ssh
systemctl enable docker
systemctl start docker

echo "=== Configuration système terminée ==="