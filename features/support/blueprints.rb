require 'rubygems'
require 'machinist/active_record'
require 'ffaker'

Before { Sham.reset } # reset Shams in between scenarios

Sham.name { Faker::Name.name }
Sham.email { Faker::Internet.email }

User.blueprint do
  name
  username { self.name.gsub(' ', '.') }
  role { "contributor" }
  email
end

Sham.title { Faker::Company.catch_phrase }
Sham.abstract { Faker::Lorem.paragraphs }

Adapt::Study.blueprint do
  owner { User.make }
  title
  abstract
end
