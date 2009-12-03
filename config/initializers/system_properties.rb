require 'java'

# -- read some missing environment variables from the Java system properties
for key in %w{ADAPT_IS_LOCAL ADAPT_DB_ADAPTER ADAPT_DB_PATH ADAPT_ASSET_PATH
              ASSDA_OPENID_SERVER ASSDA_REGISTRATION_URL}
  ENV[key] ||= java.lang.System.getProperty(key)
end

ENV['HOME'] ||= java.lang.System.getProperty('user.home')

# -- set some values to their defaults if unspecified
ENV['ASSDA_OPENID_SERVER'] ||= "http://openid.assda.edu.au/joid/user/"
ENV['ASSDA_REGISTRATION_URL'] ||= "http://assda.anu.edu.au/online_reg.php"
