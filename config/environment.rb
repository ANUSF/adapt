require 'java'
System = java.lang.System

ENV['RAILS_DB_PATH'] ||= System.getProperty('RAILS_DB_PATH')
ENV['RAILS_IS_LOCAL'] ||= System.getProperty('RAILS_IS_LOCAL')
ENV['RAILS_USER_HOME'] ||= System.getProperty('user.home')

RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem "haml"
  config.gem "authlogic"

  # -- These two must be set in warble.rb for some reason
  #config.gem "activerecord-jdbcsqlite3-adapter"
  #config.gem "bcrypt-ruby"

  config.time_zone = 'Canberra'

  config.after_initialize do
    migration_path = RAILS_ROOT + "/db/migrate"
    ActiveRecord::Migrator.migrate(migration_path)
  end
end
