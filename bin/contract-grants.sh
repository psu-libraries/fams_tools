BACKUPS_USERNAME=$1
BACKUPS_PASSWORD=$2

#!/bin/bash

# Grab dmresults.csv from SIMS
wget https://service.sims.psu.edu/digitalmeasures/dmresults_effort.csv -O app/parsing_files/contract_grants.csv

# Grab CONGRANT.csv from Digital Measures
wget --user $BACKUPS_USERNAME --password $BACKUPS_PASSWORD \
https://webservices.digitalmeasures.com/login/service/v4/SchemaData:backup/INDIVIDUAL-ACTIVITIES-University \
-O app/parsing_files/backups.zip

# Unzip to expose CONGRANT.csv
unzip -d app/parsing_files/ app/parsing_files/backups.zip
