[![CircleCI](https://circleci.com/gh/psu-stewardship/ai_integration.svg?style=svg&circle-token=5c9a5398c9ab15e080b43393e0b3a04c96eff031)](https://circleci.com/gh/psu-stewardship/ai_integration)

# AI Integration (FAMS Tools)

This app parses data from faculty CVs, and integrates data into Activity Insight.  It also stores backups of the Activity Insight database.


## Dependencies

  -ruby 2.5.1

  -mariadb 10.2

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
  
  * The Lionpath integration is fully automated and runs on a cron schedule.  Contract/Grants will be fully automated soon.  The rest must be run by using the GUI.  Usage instructions are on the homepage.
  
  * Further documentation for this application can be found on its root page (/).  Documentation for the CV Parser can be found there.
  
  * The CV Parser uses the AnyStyle gem to parse/pasted citations through a web form.  The subsequently parsed data can then be edited and updated in another form to get the data properly formatted.  The data can be exported as a csv or xlsx file.
  
## Development

  After running the container, any changes to the code on your local machine will change in the container.  Sometimes the rails server needs to be restarted to pick up certain changes.  To do this run:
  
  `bundle exec rails restart`
  
  from inside the web container.
  
## Testing
  
  From within the web container
  
  `RAILS_ENV=test bundle exec rspec`
  
  *Note: The integration specs are not ideal.  They do not give a particularly useful error message when they fail.  To better understand what is causing a failure, put a byebug somewhere in the code you are testing and follow the byebug until an error shows.  Use byebug to return the error.*

## Documentation

* Setting up Capybara with Webkit in a Docker Container: https://sites.psu.edu/dltdocs/?p=4767


