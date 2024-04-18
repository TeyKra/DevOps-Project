# DEVOPS - TP1: Docker

## Objectives
- Create a GitHub repository named after your EFREI identifier.
- Develop a wrapper that retrieves the weather for a given location using its latitude and longitude (passed as environment variables), utilizing the OpenWeather API. You may use the programming language of your choice (bash, python, go, nodejs, etc.).
- Package your code in a Docker image.
- Publish your Docker image on DockerHub.
- Make your code accessible in a GitHub repository.

## Deliverables

1. Public GitHub repository URL containing the Dockerfile and wrapper code.
2. Public DockerHub registry URL where your Docker image is hosted.
3. A report detailing your technical choices, commands used, and challenges faced if the task wasn't completed. This report should be emailed no later than 48 hours after the TP ends to the professor's email with the subject: `[TP1-DEVOPS] LAST NAME FIRST NAME`.

## Grading Criteria

- Code availability on GitHub.
- A Dockerfile that successfully builds.
- Docker image availability on DockerHub.
- Functionality of the API, verifiable by running the following command with your Docker image:

docker run --env LAT="31.2504" --env LONG="-99.2506" --env API_KEY=****yourregistry/api:1.0.0


## Bonus Points

Earn bonus points for:

- No CVEs (Common Vulnerabilities and Exposures) as reported by `trivy`:

trivy image yourregistry/api:1.0.0

- No lint errors in the Dockerfile as reported by `hadolint`:

docker run --rm -i hadolint/hadolint < Dockerfile

- Ensuring no sensitive data (e.g., OpenWeather API key) is stored within the image.

# DevOps Skills Enhancement Project - CI/CD with OpenWeather API

## Introduction

In the quest to deepen DevOps skills, Practical Work #1 aims to showcase Continuous Integration and Continuous Deployment (CI/CD) using modern tools and innovative practices. The goal is to develop a simple yet functional application that queries the OpenWeather API for weather information based on provided geographical coordinates. This process includes creating a custom GitHub repository, developing a wrapper in the programming language of our choice, and encapsulating the application in a Docker image to ensure portability and ease of deployment. Finally, this image will be published on DockerHub, making our work accessible and reusable by the community. This project highlights the significance of automation and good development practices in today's tech landscape, underscoring the core principles of DevOps.

## Architecture

To meet the project's requirements, the following architecture has been employed:

### Components

- **`my_env`**: A virtual environment to include all necessary libraries for our application.
- **`src`**: The space used to store our Python script `main.py`, containing our application's wrapper.
- **`Dockerfile`**: This Docker script contains all the instructions to build our Docker image, including the base image of Python, installing dependencies from our `requirements.txt`, and the command to execute our Python script.
- **`requirements`**: A text file to list all the necessary dependencies for our application : **`requests`**

### Diagram

Below is the general structure of our project's architecture:

![Alternative Text](images/General-Shape.png)

## Code

### Wrapper `main.py`

- This Python script serves as a wrapper for the OpenWeather API. It retrieves current weather information for a location specified by latitude and longitude.
  
#### Importing modules

```python
import os
import requests
```

- **`os`** : This module provides a portable way to use operating system-dependent functionality, such as reading or writing environment variables.
requests: An external module that facilitates sending HTTP requests. It needs to be installed via pip.

#### Environment variables

```python
LATITUDE = os.getenv('LATITUDE')
LONGITUDE = os.getenv('LONGITUDE')
API_KEY = os.getenv('OPENWEATHER_API_KEY')
```

- These lines retrieve the values of the environment variables for latitude, longitude, and the OpenWeather API key. Using environment variables for this sensitive information helps secure the code.
  
#### Base URL of the API

```python
BASE_URL = "http://api.openweathermap.org/data/2.5/weather"
```

- Set the base URL to access the OpenWeather API.
  
#### Function get_weather

```python
def get_weather(latitude, longitude, api_key):
```

- This function makes the request to the OpenWeather API to obtain weather data based on the provided latitude and longitude.

#### Building the request

```python
params = {
    'lat': latitude,
    'lon': longitude,
    'appid': api_key,
    'units': 'metric'  
}
response = requests.get(BASE_URL, params=params)
```
- The necessary parameters for the API request are defined, then a GET request is sent. units='metric' indicates that the temperature will be in Celsius degrees.
  
#### Response verification

```python
response.raise_for_status()
```

- This method raises an exception if the request fails, allowing the script to handle the error rather than proceeding with an invalid response.
  
#### Processing the response

```python
data = response.json()
weather_description = data['weather'][0]['description']
temperature = data['main']['temp']
city = data['name']
country = data['sys']['country']
print(f"La météo à {city}, {country} est : {weather_description} avec une température de {temperature}°C.")
```

- Convert the response to JSON, then extract and display the weather description, temperature, city name, and country code.
  
#### Error handling

```python
except requests.exceptions.HTTPError as err:
    print(f"Erreur lors de la récupération des données météo : {err}")
except Exception as e:
    print(f"Une erreur est survenue : {e}")
```

- Handle any potential HTTP errors or other exceptions that may occur during the request.

#### Main entry point

```python
if __name__ == "__main__":
    if LATITUDE and LONGITUDE and API_KEY:
        get_weather(LATITUDE, LONGITUDE, API_KEY)
    else:
        print("Les variables d'environnement LATITUDE, LONGITUDE, et OPENWEATHER_API_KEY sont requises.")
```

- Check if the necessary variables are defined before executing the get_weather function. If they are not, an error message is displayed.

### Dockerfile `Dockerfile`

- This Dockerfile creates a Docker image for our Python weather application, using a minimal base image to reduce potential vulnerabilities.
  
#### Base image

```dockerfile
FROM python:3.9-alpine
```

- **`python:3.9-alpine`** : Use a lightweight version of a Python image based on Alpine Linux. Alpine is chosen for its small size and increased security.

#### Working directory

```dockerfile
WORKDIR /app
```

- **`WORKDIR /app`** : Sets /app as the working directory in the container. Subsequent commands will be executed in this directory.
  
#### Installing dependencies

```dockerfile
RUN apk add --no-cache build-base libffi-dev
```

- **`apk add --no-cache build-base libffi-dev`** : Install the necessary packages to compile certain Python dependencies. **`build-base`** includes compilation tools, and **`libffi-dev`** is often required for packages needing extensions.

#### Installing Python packages

```dockerfile
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
```

- Copy **`requirements.txt`** in the container, install the specified Python dependencies. Using **`--no-cache-dir`**  helps reduce the image size by avoiding storing the pip cache.

#### Copying the source code

```dockerfile
COPY src/ ./
```

- Copy the files from the source directory src/ to the working directory /app in the container. This includes the Python script and any other files necessary for running the application.

#### Environment variable for the API key

```dockerfile
ENV OPENWEATHER_API_KEY=""
```

- Set an environment variable **`OPENWEATHER_API_KEY`** that will be used by the application. The actual value of the API key should be provided at runtime, ensuring that the Docker image remains secure.

```dockerfile
CMD ["python", "./main.py"]
```

- **`CMD ["python", "./main.py"]`** : Set the default command to execute the application, launching main.py with Python. This command is executed when the container starts, unless a different command is specified at container startup.

## Test

### Wrapper

#### Definition of LATITUDE and LONGITUDE

- To configure an application or script that requires specific environment variables, such as latitude and longitude for our weather application, we can set them directly from our .**`zsh`** terminal. 

##### Input

```shell
export LATITUDE=48.8566
export LONGITUDE=2.3522
export OPENWEATHER_API_KEY=YOUR_KEY
```

##### Output

```shell
La météo à Paris, FR est : light rain avec une température de 8.66°C.
```

- The tests for our wrapper work as expected.

### Dockerfile

#### Build the Docker image

##### Input

```shell
docker build -t monappweather:latest .
```

##### Output

```shell
[+] Building 1.4s (12/12) FINISHED                                                                           docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                                         0.0s
 => => transferring dockerfile: 812B                                                                                         0.0s
 => [internal] load metadata for docker.io/library/python:3.9-alpine                                                         1.3s
 => [auth] library/python:pull token for registry-1.docker.io                                                                0.0s
 => [internal] load .dockerignore                                                                                            0.0s
 => => transferring context: 2B                                                                                              0.0s
 => [1/6] FROM docker.io/library/python:3.9-alpine@sha256:99161d2323b4130fed2d849dc8ba35274d1e1f35da170435627b21d305dad954   0.0s
 => [internal] load build context                                                                                            0.0s
 => => transferring context: 106B                                                                                            0.0s
 => CACHED [2/6] WORKDIR /app                                                                                                0.0s
 => CACHED [3/6] RUN apk add --no-cache build-base libffi-dev                                                                0.0s
 => CACHED [4/6] COPY requirements.txt ./                                                                                    0.0s
 => CACHED [5/6] RUN pip install --no-cache-dir -r requirements.txt                                                          0.0s
 => CACHED [6/6] COPY src/ ./                                                                                                0.0s
 => exporting to image                                                                                                       0.0s
 => => exporting layers                                                                                                      0.0s
 => => writing image sha256:eb12932e8ad14e7fd2c29d78a58fb2903d2e394058a8f1899447892e26607dea                                 0.0s
 => => naming to docker.io/library/monappweather:latest                                                                      0.0s

View build details: docker-desktop://dashboard/build/desktop-linux/desktop-linux/poofijn3hkuosv7f0niyf7g3t

What's Next?
  View a summary of image vulnerabilities and recommendations → docker scout quickview
```

#### Validation of the Dockerfile and the image

##### Input

```shell
docker run --rm -i hadolint/hadolint < Dockerfile
```

##### Output

```shell
-:8 DL3018 warning: Pin versions in apk add. Instead of `apk add <package>` use `apk add <package>=<version>`
```

- No errors were encountered: 0 lint errors on Dockerfile (hadolint)

#### Scan vulnerabilities with Trivy

##### Input

```shell
trivy image monappweather:latest
```

##### Output

```shell
2024-03-31T00:26:53.204+0100    INFO    Need to update DB
2024-03-31T00:26:53.204+0100    INFO    DB Repository: ghcr.io/aquasecurity/trivy-db:2
2024-03-31T00:26:53.204+0100    INFO    Downloading DB...
44.66 MiB / 44.66 MiB [-------------------------------------------------------------------------------] 100.00% 11.17 MiB p/s 4.2s
2024-03-31T00:26:58.860+0100    INFO    Vulnerability scanning is enabled
2024-03-31T00:26:58.860+0100    INFO    Secret scanning is enabled
2024-03-31T00:26:58.860+0100    INFO    If your scanning is slow, please try '--scanners vuln' to disable secret scanning
2024-03-31T00:26:58.860+0100    INFO    Please see also https://aquasecurity.github.io/trivy/v0.50/docs/scanner/secret/#recommendation for faster secret detection
2024-03-31T00:26:58.891+0100    INFO    Detected OS: alpine
2024-03-31T00:26:58.891+0100    INFO    Detecting Alpine vulnerabilities...
2024-03-31T00:26:58.896+0100    INFO    Number of language-specific files: 1
2024-03-31T00:26:58.896+0100    INFO    Detecting python-pkg vulnerabilities...

monappweather:latest (alpine 3.19.1)

Total: 0 (UNKNOWN: 0, LOW: 0, MEDIUM: 0, HIGH: 0, CRITICAL: 0)

2024-03-31T00:26:58.898+0100    INFO    Table result includes only package filenames. Use '--format json' option to get the full path to the package file.

Python (python-pkg)

Total: 2 (UNKNOWN: 0, LOW: 0, MEDIUM: 1, HIGH: 1, CRITICAL: 0)

┌───────────────────────┬────────────────┬──────────┬────────┬───────────────────┬───────────────┬──────────────────────────────────────────────────────────┐
│        Library        │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version │                          Title                           │
├───────────────────────┼────────────────┼──────────┼────────┼───────────────────┼───────────────┼──────────────────────────────────────────────────────────┤
│ pip (METADATA)        │ CVE-2023-5752  │ MEDIUM   │ fixed  │ 23.0.1            │ 23.3          │ pip: Mercurial configuration injectable in repo revision │
│                       │                │          │        │                   │               │ when installing via pip                                  │
│                       │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2023-5752                │
├───────────────────────┼────────────────┼──────────┤        ├───────────────────┼───────────────┼──────────────────────────────────────────────────────────┤
│ setuptools (METADATA) │ CVE-2022-40897 │ HIGH     │        │ 58.1.0            │ 65.5.1        │ pypa-setuptools: Regular Expression Denial of Service    │
│                       │                │          │        │                   │               │ (ReDoS) in package_index.py                              │
│                       │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2022-40897               │
└───────────────────────┴────────────────┴──────────┴────────┴───────────────────┴───────────────┴──────────────────────────────────────────────────────────┘
```

- Regarding vulnerabilities on our selected image  **`python:3.9-alpine`**,  we can see here that we have no critical vulnerabilities: **`Total: 2 (UNKNOWN: 0, LOW: 0, MEDIUM: 1, HIGH: 1, CRITICAL: 0)`**


#### Run the Docker container

##### Input

```shell
docker run --rm -e OPENWEATHER_API_KEY=b022acb509eacae0875ded1afe41a527 -e LATITUDE=31.2504 -e LONGITUDE=99.2506 monappweather  
```

##### Output

```shell
La météo à Ganzi, CN est : overcast clouds avec une température de -2.91°C.
```

#### Publish the image on Docker Hub.

##### Create an account on Docker Hub

- Link : https://hub.docker.com

#### Log in to Docker Hub from the terminal

##### Input

```shell
docker login
```

##### Output

```shell
Authenticating with existing credentials...
Login Succeeded
```

#### Tag the image

```shell
docker tag monappweather:latest mgn94/monappweather:latest
```

#### Push the image to Docker Hub

```shell
docker push mgn94/monappweather:latest
```

- We can find our image on Docker Hub : https://hub.docker.com/repository/docker/mgn94/monappweather/general

#### No sensitive data in the image

- In the completion of this TP1, we took steps to ensure that no sensitive data, such as our OpenWeather API key, was stored in the Docker image. It is a good security practice to ensure that all sensitive data are provided via environment variables at the time of container execution.

## Conclusion

In conclusion, this DevOps TP1 demonstrated an effective application of continuous integration and deployment (CI/CD) principles through the creation of a Dockerized weather application. By focusing on essential DevOps skills, such as automation, security, and accessibility, this work led to the successful implementation of a software solution that queries the OpenWeather API for weather data based on geographical coordinates. The challenges encountered, particularly in managing vulnerabilities and securing sensitive data, were carefully addressed, reinforcing the importance of good development and security practices in today's technological ecosystem. The success of this project is illustrated not only by the functionality of the application but also by its public availability on DockerHub, thereby encouraging sharing and reuse within the DevOps community.
