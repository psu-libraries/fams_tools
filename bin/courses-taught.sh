#!/bin/bash

# Using SFTP connection with Lionpath host, pull all courses taught files
sftp -P 22 -r -i ~/.ssh/id_rsa_lionpath_prod uldsrdc@prod-nfs.lionpath.psu.edu:/out/PE_RP_ACTIVITY_INSIGHT* app/parsing_files

# Single out the newest file, rename, and delete the old ones
ls -t app/parsing_files/ | head -1 | xargs -I '{}' mv app/parsing_files/{} app/parsing_files/courses_taught.csv
rm app/parsing_files/PE_RP_ACTIVITY_INSIGHT*
