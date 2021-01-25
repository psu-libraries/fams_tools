DM_USERNAME=$1
DM_PASSWORD=$2

#!/bin/bash

# Initial wget to authenticate and create cookies.txt file with session info
wget --save-cookies app/parsing_files/cookies.txt --keep-session-cookie --delete-after \
--post-data "username=$DM_USERNAME&password=$DM_PASSWORD" \
'https://www.digitalmeasures.com/login/psu/admin/authentication/authenticatePassword.do'

# Second curl to get psu-users.xls using cookies.txt with session info
curl -b app/parsing_files/cookies.txt \
'https://www.digitalmeasures.com/login/psu/admin/security/management/user/downloadUsers?selectedUsers=345' \
>> app/parsing_files/psu-users.xls

# Delete cookies.txt
rm app/parsing_files/cookies.txt
