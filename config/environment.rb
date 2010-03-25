RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

require 'java'

# -- read some missing environment variables from the Java system properties
for key in %w{ADAPT_HOME ADAPT_IS_LOCAL ADAPT_DB_ADAPTER
              ADAPT_DB_PATH ADAPT_ASSET_PATH
              ASSDA_OPENID_SERVER ASSDA_OPENID_LOGOUT ASSDA_REGISTRATION_URL}
  ENV[key] ||= java.lang.System.getProperty(key)
end

ENV['HOME'] ||= java.lang.System.getProperty('user.home') || '.'

# -- set some values to their defaults if unspecified
ENV['ADAPT_HOME'] ||= case ENV['RAILS_ENV']
                      when 'production' then "#{ENV['HOME']}/adapt"
                      when 'stage'      then "#{ENV['HOME']}/adapt_stage"
                      else                   RAILS_ROOT
                      end
ENV['ADAPT_ASSET_PATH']       ||= "#{ENV['ADAPT_HOME']}/assets"
ENV['ASSDA_OPENID_SERVER']    ||= "http://openid.assda.edu.au/joid/user/"
ENV['ASSDA_OPENID_LOGOUT']    ||= "http://openid.assda.edu.au/joid/logout.jsp"
ENV['ASSDA_REGISTRATION_URL'] ||= "http://assda.anu.edu.au/online_reg.php"

Rails::Initializer.run do |config|
  config.gem "haml"
  config.gem "ruby-openid", :lib => "openid"
  config.gem "RedCloth"
  config.gem "nokogiri"
  config.gem "partial-date"
  config.gem "verboten"

  # -- This must be set in warble.rb for some reason
  #config.gem "activerecord-jdbcsqlite3-adapter"

  config.time_zone = 'Canberra'

  config.after_initialize do
    FileUtils.mkdir_p("#{ENV['ADAPT_HOME']}/db", :mode => 0750)

    # -- automatically migrate the database on startup
    migration_path = RAILS_ROOT + "/db/migrate"
    ActiveRecord::Migrator.migrate(migration_path)

    # -- db store for OpenID has problems with some adapters
    OpenIdAuthentication.store = :file
  end
end
