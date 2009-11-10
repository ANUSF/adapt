RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

# -- read some missing environment variables from the Java system properties
require 'java'
System = java.lang.System
for key in %w{ADAPT_IS_LOCAL ADAPT_DB_ADAPTER ADAPT_DB_PATH ADAPT_ASSET_PATH}
  ENV[key] ||= System.getProperty(key)
end
ENV['HOME'] ||= System.getProperty('user.home')

Rails::Initializer.run do |config|
  config.gem "haml"
  config.gem "authlogic"
  config.gem "authlogic-oid", :lib => "authlogic_openid"
  config.gem "ruby-openid", :lib => "openid"

  # -- These must be set in warble.rb for some reason
  #config.gem "activerecord-jdbcsqlite3-adapter"
  #config.gem "bcrypt-ruby"

  config.time_zone = 'Canberra'

  config.after_initialize do
    # -- automatically migrate the database on startup
    migration_path = RAILS_ROOT + "/db/migrate"
    ActiveRecord::Migrator.migrate(migration_path)

    # -- db store for OpenID has problems with some adapters
    OpenIdAuthentication.store = :file
  end
end
