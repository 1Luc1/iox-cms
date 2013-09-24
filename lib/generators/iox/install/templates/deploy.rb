#$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
require 'bundler/capistrano'
load 'deploy/assets'

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

set :rails_env,             'production'
set :user, "tastenbox"


###############################
# CONFIGURATION
###############################
set :application, "app_name"
set :repository,  "repos"
set :server_hostname, 'server'
set :deploy_to, "deploy"

# END CONFIGURATION

set :keep_releases, 3
set :scm_passphrase,  Proc.new { Capistrano::CLI.password_prompt('Respository Password: ') }

set :use_sudo, false

default_run_options[:pty] = true


role :web, server_hostname                          # Your HTTP server, Apache/etc
role :app, server_hostname                          # This may be the same as your `Web` server
role :db,  server_hostname, :primary => true # This is where Rails migrations will run

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

after 'deploy:create_symlink', 'deploy:finishing_touches'

namespace :deploy do
  task :finishing_touches do
    run "ln -s #{deploy_to}/shared/data #{current_path}/public/"
    run "ln -s #{deploy_to}/shared/production.sqlite3 #{current_path}/db/"
    puts "DONE."
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
