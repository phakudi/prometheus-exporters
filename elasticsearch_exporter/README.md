# Elasticsearch Metrics Exporter [![Build Status](https://travis-ci.com/phakudi/prometheus-exporters.svg?branch=master)](https://travis-ci.com/phakudi/prometheus-exporters)

Prometheus Elasticsearch metrics exporter for reporting metrics to Apptuit.ai

### Installation

Elasticsearch Exporter is available via debian & yum repositories.

##### Interactive installation

For interactive installation using curl, please invoke...
 
```
bash -c "$(curl -Ls https://raw.githubusercontent.com/phakudi/prometheus-exporters/master/elasticsearch_exporter/install.sh)"
``` 

For interactive installation using wget, please invoke...

```
bash -c "$(wget -qO- https://raw.githubusercontent.com/phakudi/prometheus-exporters/master/elasticsearch_exporter/install.sh)"
```

#### Non-Interactive installation

In this mode, the installer script reads the following environment variables for the inputs it needs. 
