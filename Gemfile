source 'http://rubygems.org'

gem 'rails', '~> 3.0.1'

if defined?(JRUBY_VERSION)
  gem 'activerecord-jdbcsqlite3-adapter'
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

# -- my ANU gems stored locally
gem 'formular',       :git => "#{ENV['HOME']}/Rails/my-gems/formular"
gem 'json-accessors', :git => "#{ENV['HOME']}/Rails/my-gems/json-accessors"
gem 'partial-date',   :git => "#{ENV['HOME']}/Rails/my-gems/partial-date"

# -- my ANU gems on github
gem 'pazy',           :git => 'git@github.com:ANUSF/pazy.git'
gem 'verboten',       :git => 'git@github.com:odf/verboten.git'

group :development, :test do
  gem 'test-unit', '~> 1.2.3'
  gem 'capybara'
  gem 'cucumber-rails'
  gem 'cucumber'
  gem 'rspec-rails', '~> 2.0.0.beta.20'
  gem 'database_cleaner'
  gem 'launchy'    # So you can do Then show me the page
  gem 'machinist'
  gem 'faker'
  gem 'pickle'
end
