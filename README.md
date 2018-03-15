# Activity Insight Integration

This app will pull data from various sources, store the data in a database, and integrate that data into Activity Insight.

## Database:

  -sqlite3

## Data:

  -dmresults-tabdel.txt    *Note: This comes from dmresults.csv.  It must be converted to tab delimited text (hence dmresults-tabdel.txt) to be properly formatted.* 

  -ai-user-accounts.xls

## Dependencies:

  -rest-client

  -spreadsheet

## Usage:

  -Download OSP data in csv format: [dmresults.csv](https://service.sims.psu.edu/digitalmeasures/dmresults.csv)

  -Convert dmresults.csv to a tab delimited text file called: dmresults-tabdel.txt (Some fields contain commas so comma delimited CSV files cannot be parsed by Ruby's built in CSV parser)

  -rake osp_data:format

  -rake osp_data:filter
