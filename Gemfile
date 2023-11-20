source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# NLP gem for parsing CVs
gem 'anystyle', '~> 1.3'

# For manipulating and generating xlsx
gem 'caxlsx_rails'

# Ldap library
gem 'net-ldap'

# Test model factories
gem 'factory_bot'

# For use of newer ssh keys
gem 'bcrypt_pbkdf'
gem 'ed25519'

# For scheduled tasks
gem 'whenever'

gem 'rails', '~> 7.0.5'
# Use mysql as the database for Active Record
# ActiveRecord only works with specific versions of mysql2.
gem 'mysql2', '~> 0.5.4'

# Use Puma as the app server
gem 'puma', '~> 5.6'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 6.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'mini_racer'

# Dynamic nested forms for cv parser
gem 'cocoon'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Manipulating spreadsheets
gem 'spreadsheet'

# Http client
gem 'httparty', '~> 0.21'

# Mocking outgoing requests
gem 'webmock'

# Stream xlsx files
gem 'creek'

# UX framework
gem 'bootstrap', '~> 4.6'

# Jquery for dom manipulation
gem 'jquery-rails', '~> 4.5.1'

# PDF Reader
gem 'pdf-reader'

# ExifTool for parsing PDF metadata
gem 'exiftool_vendored', '~> 12.33'

# Needed for Ruby 3+
gem 'webrick'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 3'
  gem 'capybara-webkit'
  gem 'database_cleaner'
  gem 'headless'
  gem 'rails-controller-testing'
  gem 'rspec-rails', '~> 6.0'
  gem 'rspec-retry'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '4.0.0.rc1'
  # Audit gems for vulnerabilities
  gem 'bundle-audit'
  # Ruby code linter
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  # Code coverage
  gem 'simplecov', '~> 0.17.0'
end

group :development do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 4'
  gem 'spring-watcher-listen', '~> 2.1.0'

  # Use Capistrano for deployment
  gem 'capistrano', '~> 3.7', require: false
  gem 'capistrano-bundler', '~> 1.2', require: false
  gem 'capistrano-passenger'
  gem 'capistrano-rails', '~> 1.2', require: false
  gem 'capistrano-rbenv', '~> 2.1', require: false
  gem 'capistrano-rbenv-install'
  gem 'web-console', '~> 4.2'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
