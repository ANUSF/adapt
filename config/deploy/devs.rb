$:.unshift(File.join(ENV['rvm_path'], 'lib'))
require 'rvm/capistrano'

set :rvm_ruby_string, 'ruby-1.9.2-p180'

role :web, "web2.mgmt"
role :app, "web2.mgmt"
role :db,  "web2.mgmt", :primary => true

set :user,        "d10web"
set :use_sudo,    false
set :deploy_to,   "/data/httpd/Rails/Adapt"

# used by migrations:
set :rails_env, "devs"
