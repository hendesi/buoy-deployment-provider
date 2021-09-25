# Buoy Webservice

[![Build and Test](https://github.com/fa21-collaborative-drone-interactions/buoy-web-service/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/fa21-collaborative-drone-interactions/buoy-web-service/actions/workflows/build-and-test.yml)
[![Build Docker Compose](https://github.com/fa21-collaborative-drone-interactions/buoy-web-service/actions/workflows/docker-compose.yml/badge.svg)](https://github.com/fa21-collaborative-drone-interactions/buoy-web-service/actions/workflows/docker-compose.yml)

This repository includes an Apodini web service that runs on the buoys Rasperry Pi and offers the sensor readings at its endpoints.

## Running the Buoy Webservice

Just run the `$ docker compose up` command to start the web service.

The Raspberry Pi image provided in [BuoyAP](https://github.com/fa21-collaborative-drone-interactions/BuoyAP) already includes the necessary docker image.
Therefore no internet connection is required to start the webservice when using this image.
