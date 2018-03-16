# Activity Insight Integration

This app will pull data from various sources, store the data in a database, and integrate that data into Activity Insight.

## Database

  -Development/Test: sqlite3

## Data

  -dmresults-tabdel.txt   

  *Note: This comes from dmresults.csv.  It must be converted to tab delimited text (hence dmresults-tabdel.txt) to be properly formatted.* 

  -ai-user-accounts.xls

## Dependencies

###Gems

  -rest-client

  -spreadsheet

  -rspec-rails (development and test)

## Usage

  1. Download OSP data in csv format: [dmresults.csv](https://service.sims.psu.edu/digitalmeasures/dmresults.csv)

  2. Download ai-user information from DSRD Box. 

  (All Files > Activity Insight files & folders > OSP data for Contracts_Grants > ai-user-accounts.xls)

  3. Store these files in /data/

  4. Convert dmresults.csv to a tab delimited text file called: dmresults-tabdel.txt 

  *Note: Some fields contain commas so comma delimited CSV files cannot be parsed by Ruby's built in CSV parser*

  5. rake osp_data:format

