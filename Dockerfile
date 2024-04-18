# Utiliser une image de base officielle Python Alpine pour minimiser les vulnérabilités
FROM python:3.9-alpine

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Installer les dépendances nécessaires pour compiler certains packages Python
RUN apk add --no-cache build-base libffi-dev

# Copier le fichier des dépendances et installer les dépendances
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copier le reste des fichiers du code source de l'application dans le conteneur
COPY src/ ./

# Définir la variable d'environnement pour la clé API (la clé elle-même sera passée au runtime, pas stockée dans l'image)
ENV OPENWEATHER_API_KEY=""

# Commande pour exécuter l'application
CMD ["python", "./main.py"]
