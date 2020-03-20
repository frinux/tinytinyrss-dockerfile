#!/bin/sh -e

sleep 30

while ! pg_isready -h $DB_HOST -U $DB_USER; do
	echo waiting until $DB_HOST is ready...
	sleep 3
done

cd /var/www/html && php update_daemon2.php
