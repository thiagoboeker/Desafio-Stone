# Stoned

### Docs

ExDocs: https://thiagoboeker.github.io/Desafio-Stone/

Swagger: https://app.swaggerhub.com/apis/thiagoboeker/Stoned-Desafio-Stone/1.0.0

## Setup

To start your local Stoned server:

  * Clone this repository
  * cd to root folder
  * Check or modify the environment variables in the env.bat and .env files
  * Run in your terminal `call env.bat` case you're in a windows environment
  * Run in your terminal `source .env` case you're in a linux environment
  * Run `docker-compose -f docker-compose.yml up`
  * Access your docker-machine-ip(in case of Docker Toolbox or localhost if not) on port 4000
    like *http://host:4000/api/*

## Deployment

The Server is running in heroku: https://stoned-desafio-stone.herokuapp.com
