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
    #puts "Running migrations from #{migration_path}..."
    ActiveRecord::Migrator.migrate(migration_path)
  end
end
