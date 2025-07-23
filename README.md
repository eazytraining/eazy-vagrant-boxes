
# Ubuntu 22.04 Vagrant Box Builder

Ce projet automatise la création d'une box Vagrant Ubuntu 22.04 LTS optimisée pour le développement, en utilisant Packer avec le format HCL2 et des images cloud-init pour un build rapide.

## 🚀 Fonctionnalités

- **Ubuntu 22.04 LTS** - Dernière version stable
- **Images Cloud-init** - Build rapide et léger
- **Docker & Docker Compose** - Prêt pour la conteneurisation
- **Node.js LTS** - Environnement JavaScript moderne
- **Ansible** - Automation et configuration
- **Outils de développement** - Git, Vim, htop, etc.
- **CI/CD GitHub Actions** - Build et publication automatiques

## 📋 Prérequis

### Environnement local
- [Packer](https://www.packer.io/downloads) >= 1.9.0
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) >= 7.0
- [Vagrant](https://www.vagrantup.com/downloads) >= 2.3.0
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) >= 5.0

### GitHub Actions (automatique)
- Secrets configurés dans le repository GitHub :
  - `VAGRANT_CLOUD_USERNAME`
  - `VAGRANT_CLOUD_TOKEN`

## 🛠️ Utilisation

### Build local

1. Cloner le repository :
```bash
git clone <your-repo-url>
cd vagrant-ubuntu-box
```

2. Configurer les variables (optionnel) :
```bash
cd packer
cp variables.pkr.hcl.example variables.pkr.hcl
# Éditer les variables selon vos besoins
```

3. Lancer le build :
```bash
cd packer
packer init ubuntu22.pkr.hcl
packer build ubuntu22.pkr.hcl
```

### Build avec GitHub Actions

1. Configurer les secrets GitHub :
   - `VAGRANT_CLOUD_USERNAME` : Votre nom d'utilisateur Vagrant Cloud
   - `VAGRANT_CLOUD_TOKEN` : Token API Vagrant Cloud

2. Push sur la branche `main` ou créer un tag :
```bash
git tag v1.0.0
git push origin v1.0.0
```

3. Le workflow se lance automatiquement et publie sur Vagrant Cloud

## 📦 Utilisation de la box

Une fois publiée, utilisez la box dans vos projets :

```ruby
# Vagrantfile
Vagrant.configure("2") do |config|
  config.vm.box = "votre-username/ubuntu2204"
  config.vm.box_version = "1.0.0"
end
```

Ou en ligne de commande :
```bash
vagrant box add votre-username/ubuntu2204 --version 1.0.0
vagrant init votre-username/ubuntu2204
vagrant up
```

## 🧪 Tests

Tester la box localement :
```bash
cd tests
vagrant up
vagrant ssh -c "docker --version && node --version && ansible --version"
vagrant destroy
```

## 📁 Structure du projet

```
vagrant-ubuntu-box/
├── .github/workflows/    # GitHub Actions
├── packer/              # Configuration Packer HCL2
├── ansible/             # Playbooks Ansible
├── http/                # Configuration cloud-init
├── tests/               # Tests de validation
└── README.md
```

## 🔧 Personnalisation

### Modifier les packages installés
Éditez `ansible/main.yml` ou `ansible/roles/common/tasks/main.yml`

### Ajouter des configurations
Ajoutez vos playbooks Ansible dans le dossier `ansible/`

### Modifier la configuration cloud-init
Éditez `http/user-data`

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/amazing-feature`)
3. Commit vos changements (`git commit -m 'Add amazing feature'`)
4. Push vers la branche (`git push origin feature/amazing-feature`)
5. Ouvrir une Pull Request

## 📝 Changelog

### v1.0.0
- Version initiale avec Ubuntu 22.04 LTS
- Docker et Docker Compose intégrés
- Node.js LTS
- Configuration Ansible
- CI/CD GitHub Actions

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🆘 Support

- Créer une [issue](https://github.com/your-username/vagrant-ubuntu-box/issues)
- Documentation Packer : https://www.packer.io/docs
- Documentation Vagrant : https://www.vagrantup.com/docs
```

## VERSION
```
1.0.0
```

## tests/test-playbook.yml
```yaml
---
- name: Test Vagrant Box Configuration
  hosts: localhost
  connection: local
  gather_facts: yes
  
  tasks:
    - name: Verify essential packages are installed
      command: "which {{ item }}"
      loop:
        - git
        - docker
        - docker-compose
        - node
        - npm
        - ansible
        - vim
        - curl
        - wget
      register: package_check
      failed_when: package_check.rc != 0
      
    - name: Check Docker service status
      systemd:
        name: docker
      register: docker_status
      
    - name: Verify Docker is running
      assert:
        that:
          - docker_status.status.ActiveState == "active"
        fail_msg: "Docker service is not running"
        
    - name: Test Docker functionality
      docker_container:
        name: test-container
        image: hello-world
        state: started
        auto_remove: yes
      become: yes
      
    - name: Verify Node.js version
      command: node --version
      register: node_version
      
    - name: Check Node.js version is recent
      assert:
        that:
          - node_version.stdout | regex_search('v1[8-9]|v[2-9][0-9]')
        fail_msg: "Node.js version seems outdated: {{ node_version.stdout }}"
        
    - name: Test Ansible functionality
      ping:
      delegate_to: localhost
```