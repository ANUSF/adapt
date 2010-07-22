# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => "assda_adapt_session_#{Rails.env}",
  :secret      => '425655458519e76165710c6a7669f344097be6441ba9ab198b8103bef8922507885c432dd7c9c3733c9abbf376e56e27a67bac2bc65e6f2bd87d63ee713a9891'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
