Given /^there is an? (.*) account for (.*)$/ do |role, name|
  Given "a user: \"#{name}\" exists with role: \"#{role}\", name: \"#{name}\""
end

Given /^I am logged in as ([a-z]+ )?(.*)$/ do |role, user|
  user = model("user: \"#{user}\"")
  visit path_to("the login page")
  fill_in "login", :with => user.username
  click_button "Submit"
end

Given /^I am not logged in$/ do
  visit "/logout"
end
