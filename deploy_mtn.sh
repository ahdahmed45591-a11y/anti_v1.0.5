#!/bin/bash
# ==============================================================================
# Script de déploiement automatique BAOU Finance sur Serveur MTN Cloud
# ==============================================================================
set -e

echo "=== [1/5] Mise à jour du système & dépendances ==="
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git ufw

echo "=== [2/5] Installation de Docker & Docker Compose ==="
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
fi

echo "=== [3/5] Configuration du Pare-feu (UFW) ==="
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw allow 3000/tcp # Admin Portal
sudo ufw allow 3001/tcp # Backend API
sudo ufw --force enable

echo "=== [4/5] Génération des secrets (.env.docker) si absent ==="
if [ ! -f ".env.docker" ]; then
    DB_PASS=$(openssl rand -base64 24 | tr -d "=+/" | cut -c1-20)
    JWT_SEC=$(openssl rand -base64 48 | tr -d "=+/" | cut -c1-40)
    cat <<EOF > .env.docker
POSTGRES_DB=baou
POSTGRES_USER=baou
POSTGRES_PASSWORD=${DB_PASS}
JWT_SECRET=${JWT_SEC}
DJANGO_SECRET_KEY=${JWT_SEC}
EOF
    echo ".env.docker généré avec succès."
fi

echo "=== [5/5] Lancement des conteneurs Docker ==="
docker compose down || true
docker compose up -d --build

echo "=============================================================================="
echo " DÉPLOIEMENT TERMINÉ AVEC SUCCÈS !"
echo " Backend API : http://$(curl -s ifconfig.me):3001"
echo " Portail Admin : http://$(curl -s ifconfig.me):3000"
echo "=============================================================================="
