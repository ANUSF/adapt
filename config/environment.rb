RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  require File.join(File.dirname(__FILE__), 'read_configuration')

  config.gem "haml"
  config.gem "ruby-openid", :lib => "openid"
  config.gem "RedCloth"

  # -- ANUSF gems
  config.gem "lazy"
  config.gem "partial-date"
  config.gem "verboten"

  # -- This must be set in warble.rb for some reason
  #config.gem "activerecord-jdbcsqlite3-adapter"

  config.time_zone = 'Canberra'

  config.after_initialize do
    FileUtils.mkdir_p(File.join(ADAPT::CONFIG['adapt.home'], "db"),
                      :mode => 0750)

    # -- automatically migrate the database on startup
    migration_path = RAILS_ROOT + "/db/migrate"
    ActiveRecord::Migrator.migrate(migration_path)

    # -- db store for OpenID has problems with some adapters
    OpenIdAuthentication.store = :file
  end
end
