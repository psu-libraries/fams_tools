#!/bin/bash
# This script will set up your docker-compose build as of 02.16.2024 - author Bryan Lopez 
# Dependencies:
    # docker 
    # docker-compose 

set -e

docker_compose_setup() {
    if ! command -v docker-compose &> /dev/null && ! command -v docker &> /dev/null;
    then
        echo "-> docker-compose||docker could not be found, install first before proceeding"
        exit 1
    fi
    
    echo "-> Cleaning up previous docker-compose builds:";
    yes | docker-compose rm; 
    docker-compose down -v; 

    echo "-> Running docker compose up, creating containers:";
    docker-compose up --build;

}

echo "-> FAMS TOOLS SCRIPT: ";

while true; do
    read -p "-> Did you set up your environment variables(.env)? y/n: " yn;
    case $yn in
        [Yy]* ) docker_compose_setup; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
