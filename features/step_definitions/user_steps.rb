Given /^I have an account as "(.+)" with password "(.+)"$/ do |user, pass|
  User.create!({
                 :username => user, :email => "dummy@gmail.com",
                 :password => pass, :password_confirmation => pass,
                 :name => "Olaf", :address => "Here"
               })
end

Given /^there is an account "(.+)"$/ do |user|
  Given "I have an account as \"#{user}\" with password \"geheim\""
end
