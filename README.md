# Zerto Resiliency Observation Console
zROC for short, is a docker-compose based stack that allows you to observe Zerto API data in a visual format using Prometheus and Grafana.

The custom part of this stack is the Prometheus exporter code which is developed separately [here.](https://github.com/recklessop/Zerto_Exporter)
The rest of the stack is a standard Prometheus container and a standard Grafana container. The additional configuration files in this repo will help to configure both Prometheus and Grafana so that it can be used out of the box.

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
- VCenter username
- VCenter password

```yaml
  zertoexporter:
    image: recklessop/zerto-exporter:latest
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
      - CLIENT_ID=api-script 3 # ZVM specific info
      - CLIENT_SECRET=js51tDM8oappYUGRJBhF7bcsedNoHA5j # ZVM specific info
      - LOGLEVEL=DEBUG
      - VCENTER_HOST=192.168.40.50 # vcenter specific info
      - VCENTER_USER=administrator@vsphere.local # vcenter specific info
      - VCENTER_PASSWORD=password2 # vcenter specific info
    networks:
      - back-tier
    restart: always
```


### Multi-ZVM Configuration (Optional)

If you want to monitor more than one ZVM/vCenter you can add additional zvmexporter containers. 

For each site you want to monitor you need to copy the following yaml lines

```yaml
  zertoexporter2: # edit this if you need more than 2
    image: recklessop/zerto-exporter:latest
    command: python python-node-exporter.py
    ports:
      - "9998:9999" # edit the port for each additional exporter, in this case it was changed to 9998
    volumes:
      - ./zvmexporter/:/usr/src/logs/
    environment:
      - VERIFY_SSL=False
      - ZVM_HOST=192.168.40.60 # second ZVM specific info
      - ZVM_PORT=443
      - SCRAPE_SPEED=20 #how often should the exporter scrape the Zerto API
      - CLIENT_ID=api-script 3 # second ZVM specific info
      - CLIENT_SECRET=js51tDM8oappYUGRJBhF7bcsedNoHA5j # second ZVM specific info
      - LOGLEVEL=DEBUG
      - VCENTER_HOST=192.168.40.50 # second vcenter specific info
      - VCENTER_USER=administrator@vsphere.local # second vcenter specific info
      - VCENTER_PASSWORD=password2 # second vcenter specific info
    networks:
      - back-tier
    restart: always
```

Next, modify the prometheus configuration and add additional scrape jobs for each new exporter. You will have 4 scrape jobs for each exporter.
Notice the job names and target ports have been updated to reflect the 2nd exporter.

```yaml
  - job_name: 'ransomexporter2'
    scrape_interval: 30s
    scrape_timeout: 20s
    static_configs:
         - targets: ['zertoexporter:9998']

  - job_name: 'encryption-stats2'
    scrape_interval: 30s
    scrape_timeout: 20s
    static_configs:
         - targets: ['zertoexporter:9998']
    metrics_path: /statsmetrics

  - job_name: 'thread-stats2'
    scrape_interval: 30s
    scrape_timeout: 20s
    static_configs:
         - targets: ['zertoexporter:9998']
    metrics_path: /threads

  - job_name: 'vra-stats2'
    scrape_interval: 30s
    scrape_timeout: 20s
    static_configs:
         - targets: ['zertoexporter:9998']
    metrics_path: /vrametrics
```

The default dashboards provisioned with this stack will show stats for all sites in the graphs.

If you want to create site specific dashboards, you can clone the existing dashboards, and then edit them to include filters for "siteName" labels.


## Running 

docker-compose up -d


## Accessing Grafana

http://<IP_Address_of_Docker_Host>:3000

Login credentials are admin / metricdata

There will be several dashboards provisioned out of the box that will help monitor most metrics. Custom graphs and custom dashboards can be added too.

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
This feature is in private preview. If you would like to learn more contact your Zerto account team. With Zerto Encryption Detection enabled, Zerto looks at each write that is being protected to determine if it is encrypted data or unencrypted data. The goal is to help customers detect anomalies caused by ransomware attacks in near real time.
![Encryption Detection](/images/encryption-detection.jpg)
