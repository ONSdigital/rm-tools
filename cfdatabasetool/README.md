# cfdatabasetool

## Building
1. Run `mvn install` to build jar
1. Run `docker build . -t sdcplatform/cfdatabasetool` to build docker images

## Publish docker image
Run `docker push sdcplatform/cfdatabasetool:latest`

## Running
Run `docker run -p 9000:9000 sdcplatform/cfdatabasetool:latest`