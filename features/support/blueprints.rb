require 'rubygems'
require 'machinist/active_record'
require 'faker'

Before { Sham.reset } # reset Shams in between scenarios

Sham.name { Faker::Name.name }

User.blueprint do
  name
  username { self.name.gsub(' ', '.') }
end

Sham.title { Faker::Company.catch_phrase }
Sham.abstract { Faker::Lorem.paragraphs }

Study.blueprint do
  owner { User.make }
  title
  abstract
end
