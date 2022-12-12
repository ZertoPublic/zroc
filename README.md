# eagraf
ZVM Encryption Analyzer API Grafana stack

## Requirements
- Docker host
- docker-compose
- internet connectivity (only for downloading the containers)

## Deployment

git clone http://www.github.com/recklessop/eagraf.git


Edit docker-compose.yml, change the ZVM address and API credentials, then save the docker-compose.yaml file.

## Running 

docker-compose up -d


## Accessing Grafana

http://<IP_Address_of_Docker_Host>:3000

Login credentials are admin / zertodata

There is a default dashboard with example monitoring graphs pre-defined.
