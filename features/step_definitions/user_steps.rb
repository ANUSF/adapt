Given /^I have an account as "(.+)" with password "(.+)"$/ do |user, pass|
  User.create!({
                 :username => user, :email => "dummy@gmail.com",
                 :password => pass, :password_confirmation => pass
               })
end
