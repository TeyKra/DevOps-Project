# Utiliser une image de base officielle Python Alpine pour minimiser les vulnérabilités
FROM python:3.9-alpine

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Installer les dépendances nécessaires pour compiler certains packages Python
RUN apk add --no-cache build-base=0.5-r3 libffi-dev=3.4.4-r3

# Copier le fichier des dépendances et installer les dépendances
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copier le reste des fichiers du code source de l'application dans le conteneur
COPY src/ ./

# Définir la variable d'environnement pour la clé API 
ENV OPENWEATHER_API_KEY=""
ENV FLASK_APP=main.py

# Commande pour exécuter l'application
CMD ["flask", "run", "--host=0.0.0.0", "--port=80"]
