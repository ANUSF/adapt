def logout
  driver = Capybara.current_session.driver
  driver.process :delete, "/logout"
end

Given /^there is an? (.*) account for (.*)$/ do |role, name|
  User.make(:role => role, :name => name)
end

Given /^I am logged in as ([a-z]+ )?(.*)$/ do |role, name|
  user = User.find_by_name(name)
  visit '/logout'
  visit '/login'
  fill_in "login", :with => user.username
  click_button "Sign in"
end

Given /^I am not logged in$/ do
  logout
end
