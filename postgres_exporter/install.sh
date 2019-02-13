#!/bin/bash

IS_CURL=true
IS_WGET=false

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
			IS_WGET=true
			IS_CURL=false
			$wget -O /tmp/common.sh https://raw.githubusercontent.com/phakudi/prometheus-exporters/master/common/common.sh
		else
			echo "Neither 'curl' nor 'wget' found. Please install at least one of these packages."
			exit 1
		fi
	fi
	. /tmp/common.sh
fi

PACKAGE_NAME='postgres-exporter'
OS=$(get_os)

DEFAULT_POSTGRES_HOST='localhost'
DEFAULT_POSTGRES_PORT='5432'
DEFAULT_POSTGRES_USER='prometheus'
DEFAULT_POSTGRES_PASSWORD='prometheus'
DEFAULT_POSTGRES_URL='host=localhost port=5432 user=prometheus password=prometheus dbname=postgres sslmode=disable'

function check_valid_postgres_user() {
	local host=$1
	local port=$2
	local user=$3
	local password=$4
	res=$(PGPASSWORD="$password" psql postgres -U $user -h $host -p $port -tAc "SELECT 1 FROM pg_roles WHERE rolname='${user}'")
	rescode=$?
	if [ ! -z "$res" ] && [ $res -eq 1 ]; then
		return 1
	fi
	print_message "warn" "Invalid postgres user '$user'. Would you like to create the user? Requires you to provide the postgres root password. (y/n)?"
	read yesno
	case $yesno in
		[Yy]* ) create_postgres_user $host $port $user $password; return 1;;
		[Nn]* ) print_postgres_user_creation_help $host $port $user $password;;
	esac
	return -1
}

function create_postgres_user() {
	local host=$1
	local port=$2
	local postgres_user=$3
	local postgres_user_password=$4
	read -p "Username for PostgreSQL superuser : " postgres_root_user
	read -p "Password for PostgreSQL User '$postgres_root_user' : " -s postgres_root_password
	print_message "info" "Creating PostgreSQL user '${postgres_user}' and granting needed permissions..."
	PGPASSWORD=$postgres_root_password psql postgres -U $postgres_root_user -h ${host} -p ${port} -c "CREATE USER ${postgres_user} WITH PASSWORD '${postgres_user_password}';"
	print_message "success" "Done"
}

function print_postgres_user_creation_help() {
	print_message "info" "\n\nPlease run the following commands manually as postgres 'root' user to create user - '$3'\n\n"
	print_message "info" "PGPASSWORD=<postgres_super_password> psql postgres -U <postgres_super_user> -h $1 -p $2 -c \"CREATE USER ${3} WITH PASSWORD '$4';\"\n"
}

function configure_exporter_interactively() {
	print_message "info" "Interactive Configuration for PostgreSQL Exporter\n"
	read -p "PostgreSQL IP [$DEFAULT_POSTGRES_HOST] : " postgres_host
	postgres_host=${postgres_host:-${DEFAULT_POSTGRES_HOST}}
	read -p "PostgreSQL Port [$DEFAULT_POSTGRES_PORT] : " postgres_port
	postgres_port=${postgres_port:-${DEFAULT_POSTGRES_PORT}}
	read -p "PostgreSQL User for metrics collection [$DEFAULT_POSTGRES_USER] : " postgres_user
	postgres_user=${postgres_user:-${DEFAULT_POSTGRES_USER}}
	read -p "Password for '${postgres_user}' User : " -s postgres_user_password
	check_valid_postgres_user $postgres_host $postgres_port $postgres_user $postgres_user_password
	isvalid=$?
	if [ -z $isvalid ] || [ "$isvalid" != "1" ]; then
		read -p "Have you manually created the user? Would you like to proceed? (y/n)?" yesno
		yesno=${yesno:-y}
		case $yesno in
			[Nn]* ) exit;;
		esac
	fi
	postgres_url="host=$postgres_host port=$postgres_port user=$postgres_user password=$postgres_user_password dbname=postgres sslmode=disable"
	update_exporter_configuration "$postgres_url"
}

function configure_exporter_noninteractively() {
	print_message "info" "Command line option --interactive not found. Proceeding in non-interactive mode.\n"
	if [ -z "$POSTGRES_URL" ];
	then
		POSTGRES_URL=${DEFAULT_POSTGRES_URL}
		print_message "warn" "Env variable POSTGRES_URL not found. Using Default Datasource URL (${POSTGRES_URL}) for accessing PostgreSQL instance. Please edit /etc/default/postgres-exporter if you would like to change it later.\n"
	else
		print_message "info" "Using POSTGRES_URL=$POSTGRES_URL to configure datasource for exporter.\n"
		update_exporter_configuration $POSTGRES_URL
	fi
}

function update_exporter_configuration() {
	print_message "info" "Updating exporter configuration..."
	sed -e "s|export DATA_SOURCE_NAME=\"$DEFAULT_POSTGRES_URL\"|export DATA_SOURCE_NAME=\"${1}\"|g" -i /etc/default/postgres-exporter
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

function check_exporter_up() {
	sleep 2
	exp_url="http://localhost:9187/metrics"
	regex="^pg_up "
	if $IS_CURL; then
		res=$(curl $exp_url | egrep $regex)
	elif $IS_WGET; then
		res=$(wget -O $exp_url | egrep $regex)
	fi

	if [ ! -z "$res" ]
	then
		res=$(echo $res | cut -d" " -f2)
		if [ $res -eq 1 ]
		then
			print_message "info" "Postgres Exporter is up and scraping metrics OK\n"
			return
		else
			print_message "error" "Postgres Exporter is up but, unable to scrape metrics. Please verify logs and configuration to fix this.\n"
			return
		fi
	fi

	print_message "error" "Postgres Exporter is not running.\n"
}

trap 'post_error ${PACKAGE_NAME}' ERR
check_root
setup_log $PACKAGE_NAME
post_complete $PACKAGE_NAME

case $OS in
    RedHat)
        install_redhat $PACKAGE_NAME
        configure_exporter $0
        start_service $PACKAGE_NAME
        check_exporter_up
        ;;

    Debian)
        install_debian $PACKAGE_NAME
        configure_exporter $0
        start_service $PACKAGE_NAME
        check_exporter_up
        ;;

    *)
        print_message "error" "Your OS/distribution is not supported by this install script.\n"
        exit 1;
        ;;
esac
