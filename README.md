# Activity Insight Integration

This app will pull data from various sources, store the data in a database, and integrate that data into Activity Insight.

## Database

  -Development/Test: sqlite3

## Data

  -dmresults-tabdel.txt   

  *Note: This comes from dmresults.csv.  It must be converted to tab delimited text (hence dmresults-tabdel.txt) to be properly formatted.* 

  -psu-users.xls

  -CONGRANT-tabdel.txt

## Dependencies

**Gems**

  -rest-client

  -spreadsheet

  -rspec-rails (development and test)

## Usage (Beta Testing)

**Removing Duplicates**

  1. Duplicate records must be removed from AI before the integration.

  2. Download a backup of the AI data from: [https://www.digitalmeasures.com/login/service/v4/SchemaData:backup/INDIVIDUAL-ACTIVITIES-University](https://www.digitalmeasures.com/login/service/v4/SchemaData:backup/INDIVIDUAL-ACTIVITIES-University)

  3. `cp CONGRANT.csv path/to/ai_integration/data`

  4. Convert CONGRANT.csv as a tab delimited text file called CONGRANT-tabdel.txt and format 'ID' column to a number with 0 decimal places.

  5. `rake ai_data:remove_duplicates`

**Formatting and Populating Database**
  1. Download OSP data in csv format: [dmresults.csv](https://service.sims.psu.edu/digitalmeasures/dmresults.csv)

  2. Download ai-user (psu-users.xls) information from AI Beta Users and Security Page. 

  3. Store these files in /data/

  4. Convert dmresults.csv to a tab delimited text file called: dmresults-tabdel.txt 

  *Note: Some fields contain commas so comma delimited CSV files cannot be parsed by Ruby's built in CSV parser*

  5. `rake osp_data:format`

**Integrating to AI**

  1. `rake osp_data:integrate`

