#!/bin/bash

# Using SFTP connection with Lionpath host to pull file names in order of most to least recent
OUTPUT=$(sftp -P 22 -b bin/com_sftp_newest.bat -i ~/.ssh/id_rsa_psu_health ftp_activityinsight@dmzftp.hmc.psu.edu)

count=0
for x in $OUTPUT
do
  if [[ "$x" =~ "ume_faculty_effort" ]]; then
    sftp -P 22 -r -i ~/.ssh/id_rsa_psu_health ftp_activityinsight@dmzftp.hmc.psu.edu:/$x app/parsing_files/ume_faculty_effort.csv
    let count++
  fi
  if [[ "$x" =~ "ume_faculty_quality" ]]; then
    sftp -P 22 -r -i ~/.ssh/id_rsa_psu_health ftp_activityinsight@dmzftp.hmc.psu.edu:/$x app/parsing_files/ume_faculty_quality.csv
    let count++
  fi
  if [ count == 2 ]; then
    break
  fi
done
