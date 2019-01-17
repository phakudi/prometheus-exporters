#!/bin/bash

if [ -r ../common.sh ]; then
	. ../common/common.sh
else
	curl=$(which curl)
	r=$?
	if [ $r == 0 ]; then
		$curl -o /tmp/common.sh https://raw.githubusercontent.com/phakudi/prometheus-exporters/master/common/common.sh
	else
		wget=$(which wget)
		r=$?
		if [ $r == 0 ]; then
			$wget -O /tmp/common.sh https://raw.githubusercontent.com/phakudi/prometheus-exporters/master/common/common.sh
		else
			echo "Neither 'curl' nor 'wget' found. Please install at least one of these packages."
			exit 1
		fi
	fi
	. /tmp/common.sh
fi

PACKAGE_NAME='mysqld-exporter'
OS=$(get_os)

DEFAULT_MYSQL_HOST='localhost'
DEFAULT_MYSQL_PORT='3306'
DEFAULT_MYSQL_USER='prometheus'
DEFAULT_MYSQL_PASSWORD='prometheus'
DEFAULT_MYSQL_URL='prometheus:prometheus@(localhost:3306)/'

function check_valid_mysql_user() {
	local host=$1
	local port=$2
	local user=$3
	local password=$4
	echo "$1 $2 $3 $4"
	numrows=$(mysql -u ${user} -p${password} -h ${host} -P ${port} -e "select count(*)" 2>/dev/null)
	if [ ! -z "$numrows" ]; then
		n=$(echo $numrows | cut -d " " -f2)
		if [ $n -eq 1 ]; then
			return 1
		fi
	fi
	echo -n "Invalid mysql user '$user'. Would you like to create the user? Requires you to provide the mysql root password. (y/n)?"
	read yesno
	case $yesno in
		[Yy]* ) create_mysql_user $host $port $user $password; return 1;;
		[Nn]* ) print_mysql_user_creation_help $host $port $user $password;;
	esac
	return -1
}

function create_mysql_user() {
	local host=$1
	local port=$2
	local mysql_user=$3
	local mysql_user_password=$4
	echo -n "Password for MySQL 'root' User : "
	read -s mysql_root_password
	echo ""
	echo -n "Creating MySQL user '${mysql_user}' and granting needed permissions..."
	mysql -u root -p${mysql_root_password} -h ${host} -P ${port} -e "CREATE USER '${mysql_user}'@'localhost' IDENTIFIED BY '${mysql_user_password}';"
	mysql -u root -p${mysql_root_password} -h ${host} -P ${port} -e "GRANT PROCESS ON *.* TO '${mysql_user}'@'localhost';"
	mysql -u root -p${mysql_root_password} -h ${host} -P ${port} -e "GRANT SELECT ON performance_schema.* TO '${mysql_user}'@'localhost';"
	mysql -u root -p${mysql_root_password} -h ${host} -P ${port} -e "GRANT REPLICATION CLIENT ON *.* to '${mysql_user}'@'localhost';"
	print_message "success" "Done"
}

function print_mysql_user_creation_help() {
	print_message "info" "\n\nPlease run the following commands manually as mysql 'root' user to create user - '$3'\n\n"
	print_message "info" "mysql -u root -p -h $1 -P $2 -e \"CREATE USER '${3}'@'localhost' IDENTIFIED BY '$4';\"\n"
	print_message "info" "mysql -u root -p -h $1 -P $2 -e \"GRANT PROCESS ON *.* TO '${3}'@'localhost';\"\n"
	print_message "info" "mysql -u root -p -h $1 -P $2 -e \"GRANT SELECT ON performance_schema.* TO '${3}'@'localhost';\"\n"
	print_message "info" "mysql -u root -p -h $1 -P $2 -e \"GRANT REPLICATION CLIENT ON *.* to '${3}'@'localhost';\"\n\n"
}

function configure_exporter_interactively() {
	print_message "info" "Interactive Configuration for MySQL Exporter\n"
	echo -n "MySQL IP [$DEFAULT_MYSQL_HOST] : "
	read mysql_host
	mysql_host=${mysql_host:-${DEFAULT_MYSQL_HOST}}
	echo -n "MySQL Port [$DEFAULT_MYSQL_PORT] : "
	read mysql_port
	mysql_port=${mysql_port:-${DEFAULT_MYSQL_PORT}}
	echo -n "MySQL User for metrics collection [$DEFAULT_MYSQL_USER] : "
	read mysql_user
	mysql_user=${mysql_user:-${DEFAULT_MYSQL_USER}}
	echo -n "Password for '${mysql_user}' User : "
	read -s mysql_user_password
	echo ""
	check_valid_mysql_user $mysql_host $mysql_port $mysql_user $mysql_user_password
	isvalid=$?
	if [ -z $isvalid ] || [ "$isvalid" != "1" ]; then
		echo -n "Have you manually created the user? Would you like to proceed? (y/n)?"
		read yesno
		case $yesno in
			[Nn]* ) exit;;
		esac
	fi
	mysql_url="$mysql_user:$mysql_user_password@($mysql_host:$mysql_port)/"
	update_exporter_configuration $mysql_url
}

function configure_exporter_noninteractively() {
	print_message "info" "Command line option --interactive not found. Proceeding in non-interactive mode.\n"
	if [ -z "$MYSQL_URL" ];
	then
		print_message "warn" "Env variable MYSQL_URL not found. Using Default Datasource URL for accessing MySQL instance. Please edit /etc/default/mysqld-exporter if you would like to change it.\n"
		MYSQL_URL=${DEFAULT_MYSQL_URL}
	fi
	update_exporter_configuration $MYSQL_URL
}

function update_exporter_configuration() {
	print_message "info" "Updating exporter configuration..."
	sed -e "s|@MYSQL_URL@|${1}|g" -i /etc/default/mysqld-exporter
	print_message "info" "DONE\n"
}

function configure_exporter() {
	if [ -z "$1" ] || [ ! "$1" == "--interactive" ]
	then
		configure_exporter_noninteractively
	else
		configure_exporter_interactively
	fi
}

trap 'post_error ${PACKAGE_NAME}' ERR
check_root
setup_log $PACKAGE_NAME
post_complete $PACKAGE_NAME

case $OS in
    RedHat)
        install_redhat $PACKAGE_NAME
        configure_exporter $1
        start_service $PACKAGE_NAME
        ;;

    Debian)
        install_debian $PACKAGE_NAME
        configure_exporter $1
        start_service $PACKAGE_NAME
        ;;

    *)
        print_message "error" "Your OS/distribution is not supported by this install script.\n"
        exit 1;
        ;;
esac
