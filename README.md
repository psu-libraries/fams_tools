# Activity Insight Integration

This app will pull data from various sources, store the data in a database, and integrate that data into Activity Insight.

## Database

  -Development/Test/Production: MySQL

## Data

  -dmresults-tabdel.txt   

  *Note: This comes from dmresults.csv.  It must be converted to tab delimited text (hence dmresults-tabdel.txt) to be properly formatted.* 

  -psu-users.xls

  -CONGRANT-tabdel.txt

  -SP18-tabdel.txt

## Dependencies

**Gems**

  -httparty

  -spreadsheet

  -rspec-rails (development and test)

  -nokogiri

## Usage

*Note: Make sure the development database is properly rolled back and migrated before populating database*
*Note: Test integrations on beta and/or alpha before production*

**Formatting and Populating Database with OSP Data**

  1. Download OSP data in csv format: [dmresults.csv](https://service.sims.psu.edu/digitalmeasures/dmresults.csv)

  2. Download ai-user (psu-users.xls) information from AI Beta Users and Security Page. 

  3. Store these files in /data/

  4. Convert dmresults.csv to a tab delimited text file called: dmresults-tabdel.txt 

  *Note: Some fields contain commas so comma delimited CSV files cannot be parsed by Ruby's built in CSV parser*

  5. `rake osp_data:format`

**Formatting and Populating Database with LionPath Data**

  1. Download LionPath Spring 2018 data from box and store in /data/.

  2. Convert 'Instructor Campus ID' column to a date formatted: dd/mm/yyyy

  3. Convert SP18.csv into a tab delimited text file called SP18-tabdel.txt.

  4. `rake lionpath_data:format`
 
**Removing Duplicate CONGRANT Data**

  1. Duplicate records must be removed from AI before the integration and after populating the database.

  2. Download a backup of the AI data from: [https://www.digitalmeasures.com/login/service/v4/SchemaData:backup/INDIVIDUAL-ACTIVITIES-University](https://www.digitalmeasures.com/login/service/v4/SchemaData:backup/INDIVIDUAL-ACTIVITIES-University)

  3. `cp CONGRANT.csv path/to/ai_integration/data`

  4. Convert CONGRANT.csv as a tab delimited text file called CONGRANT-tabdel.txt and format 'ID' column to a number with 0 decimal places.

  5. `rake activity_insight:remove_duplicates`

**Integrating OSP Data into AI**

  1. `rake osp_data:integrate`

**Integrating LionPath Data into AI**

  1. `rake lionpath_data:integrate`

