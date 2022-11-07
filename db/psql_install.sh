#! /bin/bash

# echo "update repository index"

# sudo apt update

# curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg

# echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list

# sudo apt update

# sudo apt install postgresql-11

echo "variables for postgres installation"

dbdir='/postgres'
dbdata='/postgres/data'
dbgitrepo='git://git.postgresql.org/git/postgresql.git'
dbuser='postgres'
dbscript='/home/admin/db/db.sql'
logfile='postgres-log'


echo "update repository index"
apt-get update -y >> $logfile

echo "Creating folders $dbdata..."
mkdir -p $dbdata >> $logfile

echo "Creating system user '$dbuser'"
sudo adduser --system $dbuser >> $logfile

echo "Pulling down PostgreSQL from $dbgitrepo"
git clone $dbgitrepo >> $logfile

echo "Configuring PostgreSQL"
/home/admin/db/postgresql/configure --prefix=$dbdir --datarootdir=$dbdata >> $logfile

echo "Making PostgreSQL"
make >> $logfile

echo "installing PostgreSQL"
sudo make install >> $logfile

echo "Giving system user '$dbuser' control over the $dbdata folder"
sudo chown postgres $dbdata >> $logfile

echo "Running initdb"
sudo -u postgres $dbdir/bin/initdb -D $dbdata/db >> $logfile

echo "Starting PostgreSQL"
sudo -u postgres $dbdir/bin/pg_ctl -D $dbdata/db -l $dbdata/logfilePSQL start >> $logfile

echo "Set PostgreSQL to launch on startup"
sudo sed -i '$isudo -u postgres /postgres/bin/pg_ctl -D /postgres/data/db -l /postgres/data/logfilePSQL start' /etc/rc.local >> $logfile

echo "Writing PostgreSQL environment variables to /etc/profile"
cat << EOL | sudo tee -a /etc/profile
# PostgreSQL Environment Variables
LD_LIBRARY_PATH=/postgres/lib
export LD_LIBRARY_PATH
PATH=/postgres/bin:$PATH
export PATH
EOL

echo "Wait for PostgreSQL to finish starting up..."
sleep 5

echo "Running script"
$dbdir/bin/psql -U postgres -f $dbscript


export PATH=$PATH:/postgres/bin/psql >> ~/.bashrc


