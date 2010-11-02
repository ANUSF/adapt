RAILS_GEM_VERSION = '2.3.10' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # -- reads configuration parameters from various places
  require File.join(File.dirname(__FILE__), 'read_configuration')

  # -- sets the time zone for this application
  config.time_zone = 'Canberra'

  # -- gems we use
  config.gem 'activerecord-jdbcsqlite3-adapter', :lib => false
  config.gem 'jruby-openssl', :lib => false

  config.gem "haml"
  config.gem "ruby-openid", :lib => "openid"
  config.gem "RedCloth"
  config.gem "rubyzip", :lib => "zip/zip"

  config.gem 'formular'
  config.gem 'json-accessors'
  config.gem 'lazy', :lib => false
  config.gem 'partial-date'
  config.gem 'verboten'
end
