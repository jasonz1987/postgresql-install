#!/bin/sh

# Name:pgsql_yum_install.sh
# Info:A Script For Setup PostgreSQL Use Yum Repo
# Author:Jason_z
# Create:2013-05-15
# Mail:ccnuzxg@gmail.com
# CopyRight @ AnAn Studio,http://www.anan-studio.com

# Define Variables

version="9.2"

# default postgres data dir,so don't modify this !!
defaultDir=/var/lib/pgsql/$version/data
# you can also your own data dir
yourDir=/data/pg_data

# Notice:you cat get this from:http://yum.postgresql.org/repopackages.php
# if you do not kown what's your release or arch
#  type 'cat /etc/redhat_release' ,get your os release
#  type 'uname -m' ,get your os arch
rpm=http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/pgdg-centos92-9.2-6.noarch.rpm

#Check postgres installed
rpm -qa postgres

if [ $? -ne 0 ];then
	echo "PostgreSQL is installed,then will be quit."
	exit  1
fi

#Install the repo RPM
sudo rpm -ivh $rpm

#along with -contrib subpackage
sudo yum -y groupinstall "PostgreSQL Database Server $version PGDG"

if [ "$yourDir" == "$defaultDir" ];then
	sudo service postgresql-$version initdb
	sudo service postgresql-$version start
else
	if [ ! -d $yourDir ];then
		sudo mkdir -p $yourDir
		sudo chown postgres:postgres $yourDir
	fi

	#assign PG data dir 
	sudo -u postgres /usr/pgsql-$version/bin/pg_ctl -D $yourDir initdb

	#modify conf
	sudo sed -i "s/localhost/*/" $yourDir/postgresql.conf

	#modify init.d
	sudo sed -i 's $defaultDir $yourDir g' /etc/init.d/postgresql-$version 

	#start pg
	sudo -u postgres /usr/pgsql-$version/bin/pg_ctl -D $yourDir start
fi

# join in startup
sudo chkconfig postgres-$version on

#modify password
#sudo -u postgres psql -d postgres -c "alter user postgres with password '123456'"
