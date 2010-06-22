RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # -- reads configuration parameters from various places
  require File.join(File.dirname(__FILE__), 'read_configuration')

  # -- third-party gems we use
  config.gem "haml"
  config.gem "ruby-openid", :lib => "openid"
  config.gem "RedCloth"

  # -- ANUSF gems
  config.gem "formular"
  config.gem "lazy"
  config.gem "partial-date"
  config.gem "verboten"

  # -- this must be set in warble.rb for some reason
  #config.gem "activerecord-jdbcsqlite3-adapter"

  # -- sets the time zone for this application
  config.time_zone = 'Canberra'
end
