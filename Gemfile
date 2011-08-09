source 'http://rubygems.org'

gem 'rails', '3.1.0.rc4'

gem 'mongrel', '~> 1.2.0.pre2'
gem 'pg'

# Asset template engines
gem 'sass-rails'

gem 'jquery-rails'

gem 'capistrano-ext'
gem 'haml'
gem 'RedCloth'
gem 'ruby-openid',  :require => 'openid'
gem 'rubyzip',      :require => 'zip/zip'
gem 'formtastic'

gem 'devise'
gem 'devise_openid_authenticatable', '~> 1.0.0'

if ENV['GEMS_LOCAL'] and File.exist? ENV['GEMS_LOCAL']
  path = ENV['GEMS_LOCAL']
  gem 'openid_client', '~> 0.1.6', :path => "#{path}/openid_client"
  gem 'themenap',      '~> 0.1.6', :path => "#{path}/themenap"
else
  git = 'git://github.com/ANUSF'
  gem 'openid_client', '~> 0.1.6', :git => "#{git}/OpenID-Client-Engine.git"
  gem 'themenap',      '~> 0.1.6', :git => "#{git}/themenap.git"
end

group :development, :test do
  gem 'coffee-script'
  gem 'coffee-script-source', '1.1.1'
  gem 'uglifier'
  gem 'sqlite3'
  gem 'test-unit'
  gem 'capybara'
  gem 'rspec-rails'
  gem 'steak'
  gem 'simplecov', :require => false
  gem 'database_cleaner'
  gem 'selenium-webdriver'
  gem 'launchy'    # So you can do Then show me the page
  gem 'machinist'
  gem 'ffaker'
end
