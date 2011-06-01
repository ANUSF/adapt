source 'http://rubygems.org'

gem 'rails'

if defined?(JRUBY_VERSION)
  gem 'jruby-openssl'
  gem 'activerecord-jdbcsqlite3-adapter'
  gem 'activerecord-jdbcpostgresql-adapter'
else
  gem 'mongrel', '~> 1.2.0.pre2'
  gem 'sqlite3-ruby', '~> 1.2.5', :require => 'sqlite3'
  gem 'pg'
end

gem 'capistrano-ext'
gem 'haml'
gem 'sass'
gem 'RedCloth'
gem 'ruby-openid',  :require => 'openid'
gem 'rubyzip',      :require => 'zip/zip'
gem 'formtastic'

gem 'devise'


if ENV['GEMS_LOCAL'] and File.exist? ENV['GEMS_LOCAL']
  path = ENV['GEMS_LOCAL']
  gem 'devise_openid_authenticatable',
      :path => "#{path}/devise_openid_authenticatable"
  gem 'openid_client',
      :path => "#{path}/openid_client"
  gem 'themenap', '~> 0.1.4',
      :path => "#{path}/themenap"
else
  gem 'devise_openid_authenticatable',
      :git => "git://github.com/ANUSF/devise_openid_authenticatable.git"
  gem 'openid_client',
      :git => "git://github.com/ANUSF/OpenID-Client-Engine.git"
  gem 'themenap', '~> 0.1.4',
      :git => "git://github.com/ANUSF/themenap.git"
end

group :development, :test do
  gem 'test-unit'
  gem 'capybara'
  gem 'rspec-rails', '~> 2.3.1'
  gem 'steak'
  gem 'simplecov', :require => false
  gem 'database_cleaner'
  gem 'selenium-webdriver'
  gem 'launchy'    # So you can do Then show me the page
  gem 'machinist'
  gem 'ffaker'
end
