#!/bin/bash

# Get username from env variable
USERNAME=${LP_SFTP_USERNAME}

# Using SFTP connection with Lionpath host to pull file names in order of most to least recent
OUTPUT=$(sftp -P 22 -b bin/lp_sftp_newest.bat -i ~/.ssh/id_rsa_lionpath_prod $USERNAME@prod-nfs.lionpath.psu.edu)

# Single out the first PE_RP_ACTIVITY_INSIGHT and pull this down as app/parsing_files/courses_taught.csv
for x in $OUTPUT
do
  if [[ "$x" =~ "PE_RP_ACTIVITY_INSIGHT" ]]; then
    sftp -P 22 -r -i ~/.ssh/id_rsa_lionpath_prod $USERNAME@prod-nfs.lionpath.psu.edu:/out/$x app/parsing_files/courses_taught.csv
    break
  fi
done
