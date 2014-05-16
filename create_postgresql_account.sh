#!/bin/bash
/usr/lib/postgresql/9.3/bin/initdb -D /usr/local/pgsql/data
createuser vagrant --createdb
exit
