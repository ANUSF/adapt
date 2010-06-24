RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # -- reads configuration parameters from various places
  require File.join(File.dirname(__FILE__), 'read_configuration')

  # -- third-party gems we use
  config.gem "haml"
  config.gem "ruby-openid", :lib => "openid"
  config.gem "RedCloth"
  config.gem "rubyzip", :lib => "zip/zip"

  # -- ANUSF gems; these need to be installed by hand
  config.gem "formular"
  config.gem "json-accessors"
  config.gem "lazy"
  config.gem "partial-date"
  config.gem "verboten"

  # -- sets the time zone for this application
  config.time_zone = 'Canberra'
end
