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

## Eye Candy

Here are screenshots from the dashboards which ship with zROC.

### Main Zerto Metrics Dashboard
Every NOC needs some eye candy right? This dashboard is great for a heads up display to see which VPGs and VMs may be falling behind in replication.
![Zerto Metrics](/images/zerto-metrics.jpg)

### Protected VMs
This dashboard shows you how much journal storage each protected VM is using as well as how many journal disks are provisioned for each protected VM. This information is important as you approach the VRA maximums.
![Protected VMS](/images/protected-vms.jpg)

### VRA Metrics
The goal of this dashboard is to help you understand the workload on each of your VRAs. How many outgoing VMs and disks, how many incoming VMs and disks, as well as simple things like how many vCPU and vRAM are assigned to each. (great to see if any VRAs are configured differently that the others.) It also shows you the total number of recovery volumes attached to a VRA (at recovery sites) so you can tell when your VRA is approaching the maximum number of protected volumes)
![VRA Metrics](/images/vra-dashboard.jpg)

### Encryption Detection
This feature is in private preview. If you would like to learn more contact your Zerto account team. With Zerto Encryption Detection enabled, Zerto looks at each write that is being protected to determine if it is encrypted data or unencrypted data. The goal is to help customers detect anomalies caused by ransomware attacks in near real time.
![Encryption Detection](/images/encryption-detection.jpg)