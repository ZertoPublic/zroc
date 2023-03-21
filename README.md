# Zerto Resiliency Observation Console
zROC for short, is a docker-compose based stack that allows you to observe Zerto API data in a visual format using Prometheus and Grafana.

The custom part of this stack is the Prometheus exporter code which is developed seperately [here.](https://github.com/recklessop/Zerto_Exporter)
The rest of the stack is a standard Promethues container and a standard Grafana container. The additional configuration files in this repo will help to configure both Prometheus and Grafana so that it can be used out of the box.

## Requirements
- Docker host (I like using Ubuntu with docker.io and docker-compose installed)
- docker-compose
- internet connectivity (only for downloading the containers)
- After initial deployment you can run this solution offline as long as it has access to the ZVM appliances that you want to get data from.

## Deployment

git clone http://www.github.com/recklessop/zroc.git


Edit docker-compose.yml, change the ZVM address and API credentials, then save the docker-compose.yaml file.

## Running 

docker-compose up -d


## Accessing Grafana

http://<IP_Address_of_Docker_Host>:3000

Login credentials are admin / metricdata

There will be several dashboards provisioned out of the box that will help monitor most metrics. Custom graphs and custom dashboards can be added too.
