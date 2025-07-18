

# Déploiement Cloud Azure : VM, Flask, MySQL & Ansible



Ce projet permet de déployer automatiquement une application Flask connectée à MySQL sur Azure. L'automatisation s'appuie sur Terraform pour l'infrastructure, Ansible pour la configuration logicielle, et un fichier `.env` pour la gestion des variables d'environnement et des secrets.

---

---


## Architecture
- **VM Ubuntu sur Azure** : là où tourne ton appli Flask
- **MySQL Flexible Server Azure** : ta base de données, managée et sécurisée
- **Azure Storage** (optionnel) : pour stocker des fichiers statiques
- **Terraform** : crée tout l’infra automatiquement
- **Ansible** : installe et configure tout le nécessaire sur la VM
- **PowerShell/Bash** : pour tout orchestrer facilement

---


## Prérequis
- Un compte Azure (avec droits de création de ressources)
- [Terraform](https://www.terraform.io/downloads.html)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) (sous WSL/Linux conseillé)
- [WSL](https://docs.microsoft.com/fr-fr/windows/wsl/install) si tu es sous Windows
- Une clé SSH générée sur ta machine

---


## Fichiers importants
- `main.tf` : décrit toute l’infra Azure
- `ansible_playbook.yaml` : installe et configure tout sur la VM
- `deploy_all.ps1` : lance tout d’un coup (Terraform, SSH, SCP)
- `hosts.ini` : inventaire Ansible (attention au chemin de la clé sous WSL)
- `.env` : toutes les variables secrètes et de config
- `app.py` : ton appli Flask connectée à MySQL

---


## Déploiement pas à pas

1. Préparer le fichier `.env` : renseigner toutes les variables nécessaires (chemins SSH, IP, identifiants Azure/MySQL, etc.)
2. Lancer le déploiement de l’infrastructure :
   - Sous PowerShell :
     ```powershell
     ./deploy_all.ps1
     ```
3. Configurer la VM avec Ansible :
   - Sous WSL/Linux :
     ```bash
     ansible-playbook -i hosts.ini ansible_playbook.yaml
     ```
4. Vérifier l’application :
   - Accéder à : `http://<VM_IP>:5000`
   - Vérifier la connexion MySQL : `http://<VM_IP>:5000/test-mysql`

---


## Commandes utiles
- Connexion SSH à la VM :
  ```bash
  ssh -i ~/.ssh/id_rsa aat-cloud@<VM_IP>
  ```
- Connexion MySQL depuis la VM :
  ```bash
  mysql -h <MYSQL_HOST> -u <MYSQL_USER> -p <MYSQL_DB>
  ```
- Voir les logs Flask :
  ```bash
  sudo journalctl -u flaskapp -f
  ```

---


## Conseils & Sécurité
- **Ne copie jamais ta clé privée SSH sur la VM !**
- Utilise toujours `.env` pour les secrets (jamais en dur dans le code)
- Vérifie le chemin de la clé SSH dans `hosts.ini` (Windows ≠ WSL)
- Ouvre les ports nécessaires dans Azure (5000 pour Flask, 22 pour SSH)

---


## Dépannage rapide
- **Ansible échoue sur la clé SSH ?**
  - Vérifie le chemin et les permissions (600 sur la clé)
- **MySQL refuse la connexion ?**
  - Vérifie le mot de passe, l’utilisateur, et les règles de pare-feu Azure
- **Le service Flask ne démarre pas ?**
  - Regarde les logs avec `journalctl` pour voir l’erreur

---


---

## Auteur
Projet réalisé par Aymen — Mini projet Cloud Azure, 2025.
