DM_USERNAME=$1
DM_PASSWORD=$2

#!/bin/bash

# Grab dmresults.csv from SIMS
wget https://service.sims.psu.edu/digitalmeasures/dmresults.csv -O app/parsing_files/contract_grants.csv

# Grab CONGRANT.csv from Digital Measures
wget --user $DM_USERNAME --password $DM_PASSWORD https://webservices.digitalmeasures.com/login/service/v4/SchemaData:backup/INDIVIDUAL-ACTIVITIES-University -O app/parsing_files/backups.zip
unzip -d app/parsing_files/ app/parsing_files/backups.zip
