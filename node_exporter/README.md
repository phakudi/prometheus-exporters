# Node Metrics Exporter [![Build Status](https://travis-ci.com/phakudi/prometheus-exporters.svg?branch=master)](https://travis-ci.com/phakudi/prometheus-exporters)

Prometheus Node metrics exporter for reporting metrics to Apptuit.ai

### Installation

Node Exporter is available via debian & yum repositories.

##### Interactive installation

For interactive installation using curl, please invoke...
 
```
bash -c "$(curl -Ls https://raw.githubusercontent.com/phakudi/prometheus-exporters/master/node_exporter/install.sh)"
``` 

For interactive installation using wget, please invoke...

```
bash -c "$(wget -qO- https://raw.githubusercontent.com/phakudi/prometheus-exporters/master/node_exporter/install.sh)"
```

#### Non-Interactive installation

In this mode, the installer script reads the following environment variables for the inputs it needs. 
