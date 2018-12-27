# MySQL Server Metrics Exporter [![Build Status](https://travis-ci.com/phakudi/prometheus-exporters.svg?branch=master)](https://travis-ci.com/phakudi/prometheus-exporters)

Prometheus exporter for MySQL Server metrics for reporting metrics to Apptuit.ai

### Installation

MySQL Exporter is available via debian & yum repositories.

##### Interactive installation

For interactive installation using curl, please invoke...
 
```
bash -c "$(curl -Ls https://raw.githubusercontent.com/phakudi/prometheus-exporters/master/mysqld_exporter/install.sh)"
``` 

For interactive installation using wget, please invoke...

```
bash -c "$(wget -qO- https://raw.githubusercontent.com/phakudi/prometheus-exporters/master/mysqld_exporter/install.sh)"
```

This interactive process takes you through prompts for setting up your MySQL user credentials in 
the exporter config. Also, if the user does not exist already it takes your root password as input 
to execute the following SQL commands for creating the said user on MySQL. Alternatively, based on 
your inputs it can generate the SQL commands for you to run manually as 'root' user.

```
sudo mysql -e "CREATE USER 'xcollector'@'localhost' IDENTIFIED BY 'changeme';"
sudo mysql -e "GRANT PROCESS ON *.* TO 'xcollector'@'localhost';"
sudo mysql -e "GRANT SELECT ON performance_schema.* TO 'xcollector'@'localhost';"
sudo mysql -e "GRANT REPLICATION CLIENT ON *.* to 'xcollector'@'localhost';"
```

#### Non-Interactive installation

In this mode, the installer script reads the following environment variables to find inputs. Please be sure to 
set all of them with the appropriate values before invoking the commands below.

If you have already executed the SQL commands above to create the metrics collection (defaults to 'prometheus') user manually, please use one of the following commands...


```bash
MYSQL_METRICS_USER=prometheus MYSQL_METRICS_PASSWORD=<metrics_user_password> MYSQL_HOST=<mysql_host_ip> MYSQL_PORT=<mysql_port> bash -c "$(curl -Ls https://raw.githubusercontent.com/phakudi/prometheus-exporters/master/mysqld_exporter/install.sh)"
```

```bash
MYSQL_METRICS_USER=prometheus MYSQL_METRICS_PASSWORD=<metrics_user_password> MYSQL_HOST=<mysql_host_ip> MYSQL_PORT=<mysql_port> bash -c "$(wget -qO- https://raw.githubusercontent.com/phakudi/prometheus-exporters/master/mysqld_exporter/install.sh)"
```

If you would like the installer script to create the mysql user for metrics gathering please use one of the commands below...

```bash
MYSQL_METRICS_USER=prometheus MYSQL_METRICS_PASSWORD=<metrics_user_password> MYSQL_HOST=<mysql_host_ip> MYSQL_PORT=<mysql_port> MYSQL_ROOT_PASSWORD=<mysql_root_password> bash -c "$(curl -Ls https://raw.githubusercontent.com/phakudi/prometheus-exporters/master/mysqld_exporter/install.sh)"
```

```bash
MYSQL_METRICS_USER=prometheus MYSQL_METRICS_PASSWORD=<metrics_user_password> MYSQL_HOST=<mysql_host_ip> MYSQL_PORT=<mysql_port> MYSQL_ROOT_PASSWORD=<mysql_root_password> bash -c "$(wget -qO- https://raw.githubusercontent.com/phakudi/prometheus-exporters/master/mysqld_exporter/install.sh)"
```
