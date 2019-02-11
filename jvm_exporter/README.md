# JVM Metrics Exporter [![Build Status](https://travis-ci.com/phakudi/prometheus-exporters.svg?branch=master)](https://travis-ci.com/phakudi/prometheus-exporters)

Prometheus JVM metrics exporter for reporting metrics to Apptuit.ai

### Installation

JVM Exporter is available via debian & yum repositories. It uses JMX to fetch metrics.
Please include the following command line properties in the JVM configuration to enable 
remote fetch of metrics via JMX.

```
-Dcom.sun.management.jmxremote
-Dcom.sun.management.jmxremote.port=7199
-Dcom.sun.management.jmxremote.local.only=false
-Dcom.sun.management.jmxremote.authenticate=false
-Dcom.sun.management.jmxremote.ssl=false
```

#### Non-Interactive installation

This is the default mode of installation. In this mode, the installer script assumes that you have a JVM  
up and running and have already set it up for exposing JMX port for remote RMI calls to retrieve 
metrics.

The installer reads the following environment variable(s) for the inputs it needs. Please be sure to set them up with 
the appropriate value(s) before invoking the commands below.

For default non-interactive install using curl, please use...

```bash
JVM_JMX_URL="service:jmx:rmi:///jndi/rmi://<jvm_host>:<jvm_jmx_port>" JVM_ALIAS="<jvm_alias_tag_value>" bash -c "$(curl -Ls https://raw.githubusercontent.com/phakudi/prometheus-exporters/master/jvm_exporter/install.sh)"
```

For non-interactive install using wget please use...

```bash
JVM_JMX_URL="service:jmx:rmi:///jndi/rmi://<jvm_host>:<jvm_jmx_port>" JVM_ALIAS="<jvm_alias_tag_value>" bash -c "$(wget -qO- https://raw.githubusercontent.com/phakudi/prometheus-exporters/master/jvm_exporter/install.sh)"
```

In absence of any of these environment variable(s), the installer script assumes default values for each of these 
as below...

* JVM_JMX_URL="service:jmx:rmi:///jndi/rmi://localhost:7199/jmxrmi"
* JVM_ALIAS="$(hostname -s)"

You can change these defaults anytime after installation by editing the corresponding 
environment variables in /etc/default/jvm-exporter.

##### Interactive installation

This mode of installation takes inputs interactively from the terminal to configure the exporter. 
 
For interactive installation using curl, please invoke...
 
```
bash -c "$(curl -Ls https://raw.githubusercontent.com/phakudi/prometheus-exporters/master/jvm_exporter/install.sh)" --interactive
``` 

For interactive installation using wget, please invoke...

```
bash -c "$(wget -qO- https://raw.githubusercontent.com/phakudi/prometheus-exporters/master/jvm_exporter/install.sh)" --interactive
```
