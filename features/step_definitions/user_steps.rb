def logout
  driver = Capybara.current_session.driver
  driver.process :delete, "/logout"
end

Given /^there is an? (.*) account for (.*)$/ do |role, name|
  Given "a user: \"#{name}\" exists with role: \"#{role}\", name: \"#{name}\""
end

Given /^I am logged in as ([a-z]+ )?(.*)$/ do |role, user|
  user = model("user: \"#{user}\"")
  visit '/logout'
  visit '/login'
  fill_in "login", :with => user.username
  click_button "Login via ASSDA"
end

Given /^I am not logged in$/ do
  logout
end
