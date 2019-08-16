#!/bin/bash

################################################################################
## Cleaning and Importing EMR Data into Database
## Authors: Bryan Barnard, Jing Su
## Date: Oct 2018
##
## Copyright (C) 2018 Jing Su <Jing.Su.66@gmail.com>
## This software may be modified and distributed under the terms
## of the MIT license.  See the LICENSE file for details.
################################################################################

set -e


DBHOST="${DBHOST:-dca1mgmt1.medctr.ad.wfubmc.edu}"
DBUSER="${DBUSER:-$(whoami)}"
DBNAME="${DBNAME:-precise}"


[ $# -eq 2 ] || { echo "Usage: import.sh SOURCE_FILE TARGET_TABLE"; exit 1; }

SOURCE_FILE="$1"
TARGET_TABLE="$2"

[ -f "$SOURCE_FILE" ] || { echo "error: unable to locate source file '$SOURCE_FILE'"; exit 1; }

DBCOMMAND="COPY ${TARGET_TABLE} FROM STDIN WITH CSV HEADER"

iconv -f utf-8 -t utf-8 --byte-subst="<0x%x>" "$SOURCE_FILE" | \
   tr -d '\000' | \
   sed 's/""//g' | \
   psql -h "$DBHOST" -U "$DBUSER" "$DBNAME" -e -c "$DBCOMMAND"
