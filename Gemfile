MYGEMS = "#{ENV['HOME']}/Rails/my-gems"

source 'http://rubygems.org'

gem 'rails', '~> 2.3.8'
gem 'activerecord-jdbcsqlite3-adapter'

gem "haml"
gem "ruby-openid", :require => "openid"
gem "RedCloth"
gem "rubyzip",     :require => "zip/zip"

gem 'formular',       :git => "#{MYGEMS}/formular"
gem 'json-accessors', :git => "#{MYGEMS}/json-accessors"
gem 'lazy',           :git => "#{MYGEMS}/lazy"
gem 'partial-date',   :git => "#{MYGEMS}/partial-date"
gem 'persistent',     :git => "#{MYGEMS}/persistent"
gem 'verboten',       :git => "#{MYGEMS}/verboten"

group :test do
  gem "webrat",           :require => false
  gem "cucumber",         :require => false
  gem 'cucumber-rails',   :require => false
  gem 'database_cleaner', :require => false
  gem "machinist"
  gem "faker"
  gem "pickle",           :require => false

  gem 'rspec-rails', '>= 1.3.2', :require => false
end
