# Don't check stuff, we know exactly what we want.
%undefine __check_files

%global mysqld_exporter_dir /opt/prometheus/mysqld_exporter
%global rootdir       		%{_topdir}/..

Name:           @RPM_PACKAGE_NAME@
Group:          System/Monitoring
Version:        @PACKAGE_VERSION@
Release:        @PACKAGE_REVISION@
Distribution:   buildhash=@GIT_FULLSHA1@
License:        @PACKAGE_LICENSE@
Summary:        @RPM_PACKAGE_NAME@ - Data collection agent for apptuit.ai
URL:            http://apptuit.ai/promex.html
Provides:       @RPM_PACKAGE_NAME@ = @PACKAGE_VERSION@-@PACKAGE_REVISION@_@GIT_SHORTSHA1@
Packager:       Prom Exporter Maintainers <hello+promex@apptuit.ai>
Requires:       initscripts

%description
Prometheus MySQL collector packaged as RPM that pushes metrics to Apptuit.AI

%install

mkdir -p %{buildroot}/etc/init.d/
%{__install} -m 0755 -D %{rootdir}/assets/sysvinit/etc/init.d/mysqld-exporter %{buildroot}/etc/init.d/mysqld-exporter

mkdir -p %{buildroot}/etc/default/
%{__install} -m 0755 -D %{rootdir}/assets/sysvinit/etc/default/mysqld-exporter %{buildroot}/etc/default/mysqld-exporter

# Install Base files
mkdir -p %{buildroot}%{mysqld_exporter_dir}/bin/
%{__install} -m 0755 -D %{rootdir}/build-tmp/@SRC_PKG_BASE_NAME@/mysqld_exporter %{buildroot}%{mysqld_exporter_dir}/bin/mysqld_exporter


%files

%attr(755, -, -) /etc/init.d/mysqld-exporter
%attr(600, -, -) /etc/default/mysqld-exporter
%dir %{mysqld_exporter_dir}
%{mysqld_exporter_dir}/bin/mysqld_exporter


%pre
is_systemd=0

if [ -d /run/systemd/system ]; then
   is_systemd=1
fi

if [ "$1" = "2" ]; then
    # stop previous version of @RPM_PACKAGE_NAME@ service before starting upgrade
    if [ $is_systemd -eq 1 ]
    then
		service @RPM_PACKAGE_NAME@ stop
	else
		/etc/init.d/@RPM_PACKAGE_NAME@ stop
	fi
fi

%post

is_systemd=0

if [ -d /run/systemd/system ]; then
   is_systemd=1
fi

PROMETHEUS_USER="prometheus"
PROMETHEUS_GROUP="prometheus"

if [ -z "$(getent group $PROMETHEUS_GROUP)" ]; then
  groupadd --system $PROMETHEUS_GROUP
else
  echo "Group [$PROMETHEUS_GROUP] already exists"
fi

if [ -z "$(id $PROMETHEUS_USER)" ]; then
  useradd --system --home-dir /home/prometheus --no-create-home \
  -g $PROMETHEUS_GROUP --shell /sbin/nologin $PROMETHEUS_USER
else
  echo "User [$PROMETHEUS_USER] already exists"
fi

chown -R $PROMETHEUS_USER.$PROMETHEUS_GROUP /opt/prometheus/mysqld_exporter

mkdir -p /var/log/prometheus/mysqld_exporter
chown -R $PROMETHEUS_USER.$PROMETHEUS_GROUP /var/log/prometheus/mysqld_exporter

if [ $is_systemd -eq 1 ]
then
	systemctl daemon-reload && systemctl enable mysqld-exporter
fi

chkconfig --add mysqld-exporter


%preun
is_systemd=0

if [ -d /run/systemd/system ]; then
   is_systemd=1
fi

if [ "$1" = "0" ]; then
    # stop service before starting the uninstall
    if [ $is_systemd -eq 1 ]
    then
    	service mysqld-exporter stop
    else
    	/etc/init.d/mysqld-exporter stop
    fi
    chkconfig --del mysqld-exporter
fi

%postun
# $1 --> if 0, then it is a deinstall
# $1 --> if 1, then it is an upgrade
if [ $1 -eq 0 ] ; then
    # This is a removal, not an upgrade
    #  $1 versions will remain after this uninstall

    # Clean up collectors
    rm -f /etc/init.d/mysqld-exporter
fi
