source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# NLP gem for parsing CVs
gem 'anystyle', '~> 1.3'

# For manipulating and generating xlsx
gem 'axlsx'
gem 'axlsx_rails'

# Ldap library
gem 'net-ldap'

# Test model factories
gem 'factory_bot'

# For use of newer ssh keys
gem 'ed25519'
gem 'bcrypt_pbkdf'

# For scheduled tasks
gem 'whenever'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'
# Use mysql as the database for Active Record
# ActiveRecord only works with specific versions of mysql2.
gem 'mysql2' , '< 0.5'

# Use Puma as the app server
gem 'puma', '~> 4.3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'mini_racer'
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Manipulating spreadsheets
gem 'spreadsheet'

# Http client
gem 'httparty'

# Mocking outgoing requests
gem 'webmock'

# Stream xlsx files
gem 'creek'

# UX framework
gem 'bootstrap'

# Jquery for dom manipulation
gem 'jquery-rails'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem "capybara-webkit"
  gem 'headless'
  gem 'selenium-webdriver'
  gem 'rspec-rails'
  gem 'shoulda-matchers', '4.0.0.rc1'
  gem 'rails-controller-testing'
  gem 'rspec-retry'
  gem 'database_cleaner'
  # Audit gems for vulnerabilities
  gem 'bundle-audit'
  # Ruby code linter
  gem 'rubocop', require: false
  # Code coverage
  gem 'simplecov', require: false
end

group :development do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Use Capistrano for deployment
  gem 'capistrano', '~> 3.7', require: false
  gem 'capistrano-bundler', '~> 1.2',require: false
  gem 'capistrano-rails', '~> 1.2', require: false
  gem 'capistrano-rbenv', '~> 2.1', require: false
  gem 'capistrano-rbenv-install'
  gem 'capistrano-passenger'
  gem 'web-console', '>= 3.3.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
