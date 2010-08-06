RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # -- reads configuration parameters from various places
  require File.join(File.dirname(__FILE__), 'read_configuration')

  # -- sets the time zone for this application
  config.time_zone = 'Canberra'
end
