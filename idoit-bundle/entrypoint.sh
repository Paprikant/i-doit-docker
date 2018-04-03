#!/bin/bash

echo "Starting mariadb..."

# THis block runs only on first start
if [ ! -f /initial ]; then
  mysql_install_db

  /bin/sh -c 'mysqld --user mysql &'

  dockerize -wait unix:///var/run/mysqld/mysqld.sock

  echo "First start..."
  echo "Running i-doit setup. This can take a while..."

  # Set mariadb superuser password
  mysql -uroot -ppassword -e "USE mysql; FLUSH PRIVILEGES; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MARIADB_SUPERUSER_PASSWORD}' WITH GRANT OPTION;"

  # Run i-doit setup
  cd $INSTALL_DIR/setup
  ./install.sh -n ${IDOIT_TENANT} -s "idoit_system" -m "idoit_data" -h localhost -p $MARIADB_SUPERUSER_PASSWORD -a $IDOIT_ADMINCENTER_PASSWORD -q

  # Create database user for i-doit
  echo "Preparing database..."
  mysql -uroot -p$MARIADB_SUPERUSER_PASSWORD -e "GRANT ALL PRIVILEGES ON idoit_data.* TO ${MARIADB_IDOIT_USERNAME}@'%' IDENTIFIED BY '${MARIADB_IDOIT_PASSWORD}';"
  mysql -uroot -p$MARIADB_SUPERUSER_PASSWORD -e "GRANT ALL PRIVILEGES ON idoit_system.* TO ${MARIADB_IDOIT_USERNAME}@'%' IDENTIFIED BY '${MARIADB_IDOIT_PASSWORD}';"
  mysql -uroot -pMARIADB_SUPERUSER_PASSWORD -e "UPDATE idoit_system.isys_mandator SET isys_mandator__db_user = '${MARIADB_IDOIT_USERNAME}', isys_mandator__db_pass = '${MARIADB_IDOIT_PASSWORD}';"

  # Change config to use new mariadb user
  echo "Setting up i-doit config..."
  sed -i "s/\"user\" => \"root\"/\"user\" => \"${MARIADB_IDOIT_USERNAME}\"/g" ${INSTALL_DIR}/src/config.inc.php
  sed -i "s/\"pass\" => \"${MARIADB_SUPERUSER_PASSWORD}\"/\"pass\" => \"${MARIADB_IDOIT_PASSWORD}\"/g" ${INSTALL_DIR}/src/config.inc.php
  chown "$APACHE_USER":"$APACHE_GROUP" ${INSTALL_DIR}/src/config.inc.php

  # Make sure bootstrapping happens only once
  touch /initial
else
  /bin/sh -c 'mysqld --user mysql &'
  dockerize -wait unix:///var/run/mysqld/mysqld.sock
fi
echo "Starting webserver..."
apache2ctl start


echo "i-doit up and running..."
dockerize -stderr /var/log/mysql/error.log -stderr /var/log/apache2/error.log -stderr /var/www/html/log/system -stderr /var/www/html/log/exception.log
