#!/bin/sh -e

while ! pg_isready -h $DB_HOST -U $DB_USER; do
	echo waiting until $DB_HOST is ready...
	sleep 3
done

export PGPASSWORD=$DB_PASS 

PSQL="psql -q -h $DB_HOST -U $DB_USER $DB_NAME"

$PSQL -c "create extension if not exists pg_trgm"

if ! $PSQL -c 'select * from ttrss_version'; then
    echo "Create database schema"
	$PSQL < /var/www/html/schema/ttrss_schema_pgsql.sql
fi

echo "Launch Apache2"
exec apache2-foreground
