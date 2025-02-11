# Zerto Resiliency Observation Console
zROC for short, is a docker-compose based software stack that allows you to observe standard Zerto API data in a visual format using Prometheus and Grafana.

The custom part of this stack is the Prometheus exporter code which is developed separately [here.](https://github.com/recklessop/Zerto_Exporter)
The rest of the stack is a standard Prometheus container and a standard Grafana container. The additional configuration files in this repo help to configure both Prometheus and Grafana to deliver customer value out of the box.

While some dashboards are pre-build the project maintainers encourage you to build your own custom dashboards or copy and modify existing dashboards to what best suits your needs.

# Legal Disclaimer
This script is open-source and is not supported under any Zerto support program or service. The author and Zerto further disclaim all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.

In no event shall Zerto, its authors or anyone else involved in the creation, production or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or the inability to use the sample scripts or documentation, even if the author or Zerto has been advised of the possibility of such damages. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.

## What it does and does not do

### Supported
- ZVM Appliance for VMware (Linux based ZVM)

### Not Supported
- Windows-based ZVM
- Zerto Cloud Appliance for Azure or AWS

## Requirements
- Docker host (I like using Ubuntu with docker.io and docker-compose installed)
- docker-compose
- internet connectivity (only for downloading the containers)
- After initial deployment you can run this solution offline as long as it has access to the ZVM appliances that you want to get data from.

## Deployment

git clone http://www.github.com/recklessop/zroc.git

## Configuration

Edit docker-compose.yml, and provide values for the following variables for the zvmexporter container.

- ZVM IP or hostname
- ZVM client id (generate this in keycloak)
- ZVM client secret (also generated in keycloak)
- VCenter ip or hostname
- VCenter username (Optional - Also this can be a read only user. As it is just used to pull VRA CPU/Memory stats from vCenter)
- VCenter password

```yaml
  zertoexporter:
    image: recklessop/zerto-exporter:stable
    command: python python-node-exporter.py
    ports:
      - "9999:9999" # edit the port for each additional exporter, in this case it was changed to 9998
    volumes:
      - ./zvmexporter/:/usr/src/logs/
    environment:
      - VERIFY_SSL=False
      - ZVM_HOST=192.168.40.60 # ZVM specific info
      - ZVM_PORT=443
      - SCRAPE_SPEED=20 #how often should the exporter scrape the Zerto API in seconds
      - CLIENT_ID=api-script # ZVM specific info
      - CLIENT_SECRET=js51tDM8oappYUGRJBhF7bcsedNoHA5j # ZVM specific info
      - LOGLEVEL=DEBUG
      - VCENTER_HOST=192.168.40.50 # vcenter specific info
      - VCENTER_USER=administrator@vsphere.local # vcenter specific info
      - VCENTER_PASSWORD=password # vcenter specific info
    networks:
      - back-tier
    restart: always
```


### Multi-ZVM Configuration (Optional)

If you want to monitor more than one ZVM/vCenter you can add additional zvmexporter containers. 

For each site you want to monitor you need to have an exporter configured like the lines below. By default the docker-compose.yaml has two exporters for a production and DR site, but you can add more sites to achieve a single pain of glass for monitoring all the ZVM's that are reachable from your docker host.

```yaml  
  zertoexporter:
    container_name: zvmexporter1
    hostname: zvmexporter1 # this hostname will need to be set in the prometheus.yaml file as well
    image: recklessop/zerto-exporter:stable
    command: python python-node-exporter.py
    ports:
      - "9999:9999"
    volumes:
      - ./zvmexporter/:/usr/src/app/logs/
    environment:
      # Site 1 configuration settings
      - VERIFY_SSL=False
      - ZVM_HOST=192.168.50.60
      - ZVM_PORT=443
      - SCRAPE_SPEED=20 #how often should the exporter scrape the Zerto API
      - CLIENT_ID=api-script
      - CLIENT_SECRET=js51tDM8oappYUGRJBhF7bcsedNoHA5j
      - LOGLEVEL=DEBUG
      - VCENTER_HOST=192.168.50.50
      - VCENTER_USER=administrator@vsphere.local
      - VCENTER_PASSWORD=password
    networks:
      - back-tier
    restart: always
```

Next, modify the prometheus configuration and add additional targets for each scrape job.
Notice the hostname is all that has been updated to reflect the 2nd exporter. (the hostname is whatever you set in the docker-compose.yaml file.

```yaml
 global:
  scrape_interval:     60s
  evaluation_interval: 60s 
  scrape_timeout: 60s

scrape_configs:
  - job_name: 'vm-stats'
    scrape_interval: 30s
    scrape_timeout: 20s
    static_configs:
         - targets: ['zvmexporter1:9999']
         #- targets: ['zvmexporter2:9999'] # only needed if you have two ZVMs to monitor

  - job_name: 'encryption-stats'
    scrape_interval: 30s
    scrape_timeout: 20s
    metrics_path: /statsmetrics
    static_configs:
         - targets: ['zvmexporter1:9999']
         #- targets: ['zvmexporter2:9999'] # only needed if you have two ZVMs to monitor


  - job_name: 'thread-stats'
    scrape_interval: 30s
    scrape_timeout: 20s
    metrics_path: /threads
    static_configs:
         - targets: ['zvmexporter1:9999']
         #- targets: ['zvmexporter2:9999'] # only needed if you have two ZVMs to monitor

  - job_name: 'vra-stats'
    scrape_interval: 30s
    scrape_timeout: 20s
    metrics_path: /vrametrics
    static_configs:
         - targets: ['zvmexporter1:9999']
         #- targets: ['zvmexporter2:9999'] # only needed if you have two ZVMs to monitor
```

The default dashboards provisioned with this stack will show stats for all sites in the graphs.

If you want to create site specific dashboards, you can clone the existing dashboards, and then edit them to include filters for "siteName" labels.


## Running 

docker-compose up -d


## Accessing Grafana

http://<IP_Address_of_Docker_Host>:3000

Login credentials are admin / zertodata

(you can change this by changing the grafana environment variable in the docker-compose.yaml file.

```
  grafana:
    image: grafana/grafana
...
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=zertodata
...
```

There will be several dashboards provisioned out of the box that will help monitor most metrics. Custom graphs and custom dashboards can be added too.

## Troubleshooting

To make sure that the exporter is able to collect data you can browse to http://dockerip:9999 or :9998 if you have a second site and look in the logs directory for the exporter logs. You can also verify that the various metric files are being created.

## Eye Candy

Here are screenshots from the dashboards which ship with zROC.

### Main Zerto Metrics Dashboard
Every NOC needs some eye candy right? This dashboard is great for a heads-up display to see which VPGs and VMs may be falling behind in replication.
![Zerto Metrics](/images/zerto-metrics.jpg)

### Protected VMs
This dashboard shows you how much journal storage each protected VM is using as well as how many journal disks are provisioned for each protected VM. This information is important as you approach the VRA maximums.
![Protected VMS](/images/protected-vms.jpg)

### VRA Metrics
The goal of this dashboard is to help you understand the workload on each of your VRAs. How many outgoing VMs and disks, how many incoming VMs and disks, as well as simple things like how many vCPU and vRAM are assigned to each. (great to see if any VRAs are configured differently that the others.) It also shows you the total number of recovery volumes attached to a VRA (at recovery sites) so you can tell when your VRA is approaching the maximum number of protected volumes)
![VRA Metrics](/images/vra-dashboard.jpg)

### Encryption Detection
With Zerto Encryption Detection enabled, Zerto looks at each write that is being protected to determine if it is encrypted data or unencrypted data. The goal is to help customers detect anomalies caused by ransomware attacks in near real time.
![Encryption Detection](/images/encryption-detection.jpg)
