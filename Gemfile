source 'http://rubygems.org'

gem 'rails', '3.1.0'

gem 'mongrel', '~> 1.2.0.pre2'
gem 'sqlite3-ruby', '~> 1.2.5', :require => 'sqlite3' # for CentOS 5.5
gem 'pg'

# Gems used only for assets.
group :assets do
  gem 'sass-rails', " ~> 3.1.0"
  gem 'coffee-rails', " ~> 3.1.0"
  gem 'uglifier'
end

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
  gem 'openid_client', :path => "#{path}/openid_client"
  gem 'themenap',      :path => "#{path}/themenap"
else
  git = 'git://github.com/ANUSF'
  gem 'openid_client', :git => "#{git}/OpenID-Client-Engine.git"
  gem 'themenap',      :git => "#{git}/themenap.git"
end

group :development, :test do
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
