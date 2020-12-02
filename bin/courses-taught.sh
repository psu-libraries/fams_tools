#!/bin/bash

# Using SFTP connection with Lionpath host, pull 4 most recent files
OUTPUT=$(sftp -P 22 -b lp_sftp_newest.bat -i ~/.ssh/id_rsa_lionpath_prod uldsrdc@prod-nfs.lionpath.psu.edu | head -10)

# Single out the first PE_RP_ACTIVITY_INSIGHT and pull this down as app/parsing_files/courses_taught.csv
for x in $OUTPUT
do
  echo $x
  if [[ "$x" =~ "PE_RP_ACTIVITY_INSIGHT" ]]; then
    sftp -P 22 -r -i ~/.ssh/id_rsa_lionpath_prod uldsrdc@prod-nfs.lionpath.psu.edu:/out/$x app/parsing_files/courses_taught.csv
    break
  fi
done
