#!/bin/bash

# Get username from env variable
USERNAME=${FAMS_LP_SFTP_USERNAME}
HOST=${FAMS_LP_SFTP_HOST}

# Using SFTP connection with Lionpath host to pull file names in order of most to least recent
OUTPUT=$(sftp -P 22 -b bin/lp_sftp_newest.bat -i ~/.ssh/id_rsa_lionpath $USERNAME@$HOST)

# Single out the first PE_RP_ACTIVITY_INSIGHT and pull this down as app/parsing_files/courses_taught.csv
for x in $OUTPUT
do
  if [[ "$x" =~ "PE_RP_ACTIVITY_INSIGHT" ]]; then
    sftp -P 22 -r -i ~/.ssh/id_rsa_lionpath $USERNAME@$HOST:/out/$x app/parsing_files/courses_taught.csv
    break
  fi
done
