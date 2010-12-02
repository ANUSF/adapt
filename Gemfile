source 'http://rubygems.org'

gem 'rails'

if defined?(JRUBY_VERSION)
  gem 'jruby-openssl'
  gem 'activerecord-jdbcsqlite3-adapter', '~> 1.0.3'
else
  gem 'mongrel', '~> 1.2.0.pre2'
  gem 'sqlite3-ruby', :require => 'sqlite3'
end

gem 'haml'
gem 'RedCloth'
gem 'ruby-openid',  :require => 'openid'
gem 'rubyzip',      :require => 'zip/zip'
gem 'devise'
gem 'rack-openid'
gem 'devise_openid_authenticatable'
gem 'formtastic'

# -- ANUSF gems on github
gem 'pazy',     :git => 'git@github.com:ANUSF/pazy.git'
gem 'verboten', :git => 'git@github.com:ANUSF/verboten.git'

group :development, :test do
  gem 'test-unit'
  gem 'capybara'
  gem 'cucumber-rails'
  gem 'cucumber'
  gem 'rspec-rails'
  gem 'database_cleaner'
  gem 'launchy'    # So you can do Then show me the page
  gem 'machinist'
  gem 'ffaker'
end
