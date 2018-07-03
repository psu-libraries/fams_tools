# Activity Insight Integration

This app will pull data from various sources, store the data in a database, and integrate that data into Activity Insight.

## Database

  -Development/Test/Production: MySQL

## Data

  -dmresults.xlsx    

  -psu-users.xls

  -CONGRANT-tabdel.txt

  -SP18-tabdel.txt

## Dependencies

**Gems**

  -httparty

  -spreadsheet

  -rspec-rails (development and test)

  -nokogiri

  -webmock

  -creek

## Deploy

  1. `cd` to project root directory.

  2. `cap production deploy BRANCH_NAME=yourbranchname`

  *Note: To deploy master simply do:* `cap production deploy`

## Usage

*Note: Make sure the development database is properly rolled back and migrated before populating database*

*Note: Test integrations on beta and/or alpha before production*

**Importing AI User Data**

  1. This must be done first to ensure the rest of the steps work

  2. Download ai-user (psu-users.xls) information from AI Users and Security Page. 

  3. Store this in /data/

  4. `rake activity_insight:get_user_data`

**Importing Pure User IDs**

  1. `rake pure:get_user_ids`

**Formatting and Populating Database with OSP Data**

  1. Download OSP data in csv format: [dmresults.csv](https://service.sims.psu.edu/digitalmeasures/dmresults.csv)

  2. Store this in /data/

  3. Convert dmresults.csv to an xlsx file called dmresults.xlsx 

  *Note: Some fields contain commas so comma delimited CSV files cannot be parsed by Ruby's built in CSV parser.  Also CSV encoding is a nightmare*

  4. `rake osp_data:format_and_populate`

**Formatting and Populating Database with LionPath Data**

  1. Download LionPath Spring 2018 data from box and store in /data/.

  2. Convert 'Instructor Campus ID' column to a date formatted: dd-mmm-yyyy

  3. Convert SP18.csv into a tab delimited text file called SP18-tabdel.txt.

  4. `rake lionpath_data:format_and_populate`

**Population Database with Pure Data**

  1. `rake pure_data:populate_db`
 
**Removing Duplicate CONGRANT Data**

  1. Duplicate records must be removed from AI before the integration and after populating the database.

  2. Download a backup of the AI data from: [https://www.digitalmeasures.com/login/service/v4/SchemaData:backup/INDIVIDUAL-ACTIVITIES-University](https://www.digitalmeasures.com/login/service/v4/SchemaData:backup/INDIVIDUAL-ACTIVITIES-University)

  3. `cp CONGRANT.csv path/to/ai_integration/data`

  4. Format 'ID' column to a number with 0 decimal places and convert CONGRANT.csv to a tab delimited text file called CONGRANT-tabdel.txt. 

  5. `rake activity_insight:remove_duplicates`

**Integrating OSP Data into AI**

  1. `rake osp_data:integrate`

**Integrating LionPath Data into AI**

  1. `rake lionpath_data:integrate`

