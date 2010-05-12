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
  config.gem "lazy"
  config.gem "partial-date"
  config.gem "verboten"

  # -- this must be set in warble.rb for some reason
  #config.gem "activerecord-jdbcsqlite3-adapter"

  # -- sets the time zone for this application
  config.time_zone = 'Canberra'

  # -- actions performed after Rails' main initialization
  #    (should this go into 'initializers'?)
  config.after_initialize do
    # -- log the configuration parameters
    text = ADAPT::CONFIG.map { |k,v| "#{k} => #{v}" }.join("\n      ")
    if defined?(JRUBY_VERSION) && defined?($servlet_context)
      # -- apparently too early to use Rails.logger
      $servlet_context.log text
    else
      Rails.logger.info(text)
    end

    # -- make sure a directory exists for the database file
    #    (so that Rails can create the file from scratch if necessary)
    db_dir = File.dirname(ADAPT::CONFIG['adapt.db.path'])
    FileUtils.mkdir_p(db_dir, :mode => 0750)

    # -- automatically migrate the database on startup
    ActiveRecord::Migrator.migrate(File.join(RAILS_ROOT, "db", "migrate"))

    # -- db store for OpenID has problems with some adapters
    OpenIdAuthentication.store = :file
  end
end
