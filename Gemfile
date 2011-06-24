source 'http://rubygems.org'

gem 'rails'

gem 'mongrel', '~> 1.2.0.pre2'
gem 'sqlite3-ruby', '~> 1.2.5', :require => 'sqlite3'
gem 'pg'

gem 'capistrano-ext'
gem 'haml'
gem 'sass'
gem 'RedCloth'
gem 'ruby-openid',  :require => 'openid'
gem 'rubyzip',      :require => 'zip/zip'
gem 'formtastic'

gem 'devise'
gem 'devise_openid_authenticatable', '~> 1.0.0'

if ENV['GEMS_LOCAL'] and File.exist? ENV['GEMS_LOCAL']
  path = ENV['GEMS_LOCAL']
  gem 'openid_client', '~> 0.1.2', :path => "#{path}/openid_client"
  gem 'themenap',      '~> 0.1.5', :path => "#{path}/themenap"
else
  git = 'git://github.com/ANUSF'
  gem 'openid_client', '~> 0.1.2', :git => "#{git}/OpenID-Client-Engine.git"
  gem 'themenap',      '~> 0.1.5', :git => "#{git}/themenap.git"
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
