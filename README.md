[![Build Status](https://travis-ci.com/psu-stewardship/ai_integration.svg?token=aQpc68FoUpxpqgvP9XN9&branch=master)](https://travis-ci.com/psu-stewardship/ai_integration)

# Activity Insight Integration

This app parses data from faculty CVs, and integrates data into Activity Insight.  It also stores backups of the Activity Insight database.


## Dependencies

  -ruby 2.5.1

  -rvm

  -MySQL

## Setup

*Refer to the docker documentation (/docker/README.md) for proper development setup*

  Install gems

  `bundle install`

  Modify database.yml with database names and configurations.  Run:

    * `rake db:create`

    * `rake db:migrate`

## Deploy

  1. `cd` to project root directory.

  2. `cap production deploy BRANCH_NAME=yourbranchname`

  *Note: To deploy master simply do:* `cap production deploy`

## Usage

  * There are rake tasks for running the parsers, populating the db, and integrations for some of the data.  This is for older integrations and were replaced by the function of the GUI.  They are pretty straight forward to use.  Simply run the `format_and_populate` rake task for a dataset, and then run the `integrate` rake task for that same dataset.  However, I'd recommend using the GUI since it is more up-to-date.

  * The app has two major functions.  One is to parse publication and presentation metadata from CVs.  The other is to integrate various datasets into Activity Insight.  Integrations include Contract/Grants data (from OSP), Courses Taught data (from LionPath), Publication data (from Metadata DB), GPA data (from college of LA), Personal & Contact Info (from LDAP), and both publications and presentations from CVs that have been parsed by the CV Parser.  

## Documentation

* Setting up Capybara with Webkit in a Docker Container: https://sites.psu.edu/dltdocs/?p=4767