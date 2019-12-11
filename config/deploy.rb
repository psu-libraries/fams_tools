# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

# Set assets roles to occur on jobs as well as web
set :assets_role, [:web]

# application and repo settings
set :application, 'ai-integration'

#set :repo_url, "git@github.com:/psu-stewardship/#{fetch(:application)}.git"
set :repo_url, "git@github.com:psu-stewardship/ai_integration.git"

#set :repo_url, "git@git.psu.edu:devteam/rubytools.git"
#https://git.psu.edu/devteam/vmdatabase.git

set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "master"

# default user and deployment location
set :user, "deploy"
set :deploy_to, "/opt/heracles/deploy/#{fetch(:application)}"
set :use_sudo, false

# ssh key settings
set :ssh_options, {
#  keys: [File.join(ENV["HOME"], ".ssh", "id_deploy_rsa")],
  keys: [File.join(ENV["HOME"], ".ssh", "id_rsa")],
  forward_agent: true
}

# rbenv settings
set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, File.read(File.join(File.dirname(__FILE__), '..', '.ruby-version')).chomp # read from file above
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec" # rbenv settings
set :rbenv_map_bins, %w(rake gem bundle ruby rails) # map the following bins
set :rbenv_roles, :all # default value

# set passenger to just the web servers
set :passenger_roles, :web

# rails settings, NOTE: Task is wired into event stack
set :rails_env, 'production'

# whenever settings, NOTE: Task is wired into event stack
set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }
set :whenever_roles, [:app]

set :log_level, :debug
set :pty, true

# Airbrussh options
set :format_options, command_output: false

namespace :deploy do
  task :symlink_shared do
    desc 'set up the shared directory to have the symbolic links to the appropriate directories shared between servers'
    puts release_path.to_s
    on roles(:web) do
      execute "ln -sf /rubytools/#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:partner)}database.yml #{release_path}/config/database.yml"
      execute "ln -sf /rubytools/#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:partner)}secrets.yml #{release_path}/config/secrets.yml"
      execute "ln -sf /rubytools/#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:partner)}activity_insight.yml #{release_path}/config/activity_insight.yml"
      execute "ln -sf /rubytools/#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:partner)}integration_passcode.yml #{release_path}/config/integration_passcode.yml"
      execute "mkdir #{release_path}/app/parsing_files"
    end
  end
  before "deploy:assets:precompile", "deploy:symlink_shared"
  after "deploy:updated", "deploy:migrate"
end

set :linked_dirs, fetch(:linked_dirs, []).push(
  'log',
  'public/system',
  'public/psu',
  'public/log',
  'tmp/cache',
  'tmp/pids',
  'tmp/sockets',
  'tmp/uploads',
  'vendor/bundle'
)

# Default value for keep_releases is 5
set :keep_releases, 7

# Default value for keep_releases is 5, setting to 7
set :keep_releases, 7



desc "Check that we can access everything"
task :check_write_permissions do
  on roles(:all) do |host|
    if test("[ -w #{fetch(:deploy_to)} ]")
      info "#{fetch(:deploy_to)} is writable on #{host}"
    else
      error "#{fetch(:deploy_to)} is not writable on #{host}"
    end
  end
end

# Used to keep x-1 instances of ruby on a machine.  Ex +4 leaves 3 versions on a machine.  +3 leaves 2 versions
namespace :rbenv_custom_ruby_cleanup do
  desc "Clean up old rbenv versions"
  task :purge_old_versions do
    on roles(:web) do
      execute 'ls -dt ~deploy/.rbenv/versions/*/ | tail -n +3 | xargs rm -rf'
    end
  end
  after "deploy:finishing", "rbenv_custom_ruby_cleanup:purge_old_versions"
end
