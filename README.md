[![CircleCI](https://circleci.com/gh/psu-stewardship/fams_tools.svg?style=svg)](https://circleci.com/gh/psu-stewardship/fams_tools)
<a href="https://codeclimate.com/github/psu-stewardship/fams_tools/test_coverage"><img src="https://api.codeclimate.com/v1/badges/34639426df49a5ab0419/test_coverage" /></a>
<a href="https://codeclimate.com/github/psu-stewardship/fams_tools/maintainability"><img src="https://api.codeclimate.com/v1/badges/34639426df49a5ab0419/maintainability" /></a>

# FAMS Tools (AI Integration)

This app parses data from faculty CVs, and integrates data into Activity Insight.  It also stores backups of the Activity Insight database.


## Dependencies

  -ruby 2.5
  
  -rails 5.2

  -mariadb 10
  
  -docker (optional)

## Setup

  Docker build and compose dev env
  
    make build
    make up
    
  Run bash in running web container
  
  `make exec`
  
  Cleanup
  
  `make down`
  
## Deploy

  1. `cd` to project root directory.

  2. `cap production deploy BRANCH_NAME=yourbranchname`

  *Note: To deploy master simply do:* `cap production deploy`

## Usage

  * Integrations include Contract/Grants data (from OSP), Courses Taught data (from LionPath), Publication data (from Metadata DB), GPA data (from college of LA), and Personal & Contact Info (from LDAP).  The Delete Records integration takes a csv of records IDs and uses the delete resource to delete records in AI.  The app also stores Activity Insight database backups.  These backups are retrieved monthly.
  
  * The Lionpath integration is fully automated and runs on a cron schedule.  Contract/Grants is also fully automated.  The rest must be run by using the GUI.  In order for the integrations to work, the faculties tables must be updated with current faculty.  This update process is automated and updates weekly.  The Usage instructions are on the homepage.
  
  * Further documentation for this application can be found on its root page (/).  Documentation for the CV Parser can be found there.
  
  * The CV Parser uses the AnyStyle gem to parse copy/pasted citations through a web form.  The subsequently parsed data can then be edited and updated in another form to get the data properly formatted.  The data can be exported as a csv or xlsx file.
  
## Integrations

### Faculty Update

Faculty data is automatically pulled from Digital Measures and stored in the database every Sunday at 22:00.  The data is obtained from this end point: https://www.digitalmeasures.com/login/psu/admin/security/management/user/downloadUsers?selectedUsers=345

### Courses Taught

The courses taught data import runs automatically at 00:00 on February 1st, June 1st, and October 1st.  The data is obtained via sftp from LionPATH's file server (prod-nfs.lionpath.psu.edu).  The files are generated weekly on Sunday.  The data in the files update to the current semester data on the third week of that semester.  The cron dates are set to run within the first couple weeks after that.

### Contract/Grants

The contract/grant data import runs on the second Monday of every month at 01:00.  The data is obtained from the CSV generated by the SIMS team at this endpoint: https://service.sims.psu.edu/digitalmeasures/dmresults.csv .  This integration is also dependent on the CONGRANT.csv backup obtained from this Digital Measures endpoint: https://webservices.digitalmeasures.com/login/service/v4/SchemaData:backup/INDIVIDUAL-ACTIVITIES-University .  The backup is used to detect if there are any duplicates in the current Activity Insight system and remove them before the import runs.
  
## Development

  After running the container, any changes to the code on your local machine will change in the container.  Sometimes the rails server needs to be restarted to pick up certain changes.  To do this run:
  
  `bundle exec rails restart`
  
  from inside the web container.
  
## Testing
  
  From within the web container
  
  `RAILS_ENV=test bundle exec rspec`
  
  *Note: The integration specs are not ideal.  They do not give a particularly useful error message when they fail.  To better understand what is causing a failure, put a byebug somewhere in the code you are testing and follow the byebug until an error shows.  Use byebug to return the error.*

## Other Documentation

* Setting up Capybara with Webkit in a Docker Container: https://sites.psu.edu/dltdocs/?p=4767
* How to run COM data file pull example:

    cap production grab_com_data_files['~/.ssh/id_rsa']


