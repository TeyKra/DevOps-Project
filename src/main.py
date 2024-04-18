import os
import requests

# Obtenez les variables d'environnement pour la latitude, la longitude et la clé API
LATITUDE = os.getenv('LATITUDE')
LONGITUDE = os.getenv('LONGITUDE')
API_KEY = os.getenv('OPENWEATHER_API_KEY')

# URL de base de l'API OpenWeather
BASE_URL = "http://api.openweathermap.org/data/2.5/weather"

def get_weather(latitude, longitude, api_key):
    """Obtenez la météo pour une latitude et longitude donnée en utilisant l'API OpenWeather."""
    try:
        # Construire l'URL de requête
        params = {
            'lat': latitude,
            'lon': longitude,
            'appid': api_key,
            'units': 'metric'  # ou 'imperial' pour Fahrenheit
        }
        response = requests.get(BASE_URL, params=params)
        
        # Vérifier si la requête a réussi
        response.raise_for_status()

        # Traiter et afficher la réponse
        data = response.json()
        weather_description = data['weather'][0]['description']
        temperature = data['main']['temp']
        # Extraire le nom de la ville et le code du pays
        city = data['name']
        country = data['sys']['country']
        print(f"La météo à {city}, {country} est : {weather_description} avec une température de {temperature}°C.")
    except requests.exceptions.HTTPError as err:
        print(f"Erreur lors de la récupération des données météo : {err}")
    except Exception as e:
        print(f"Une erreur est survenue : {e}")

if __name__ == "__main__":
    if LATITUDE and LONGITUDE and API_KEY:
        get_weather(LATITUDE, LONGITUDE, API_KEY)
    else:
        print("Les variables d'environnement LATITUDE, LONGITUDE, et OPENWEATHER_API_KEY sont requises.")
