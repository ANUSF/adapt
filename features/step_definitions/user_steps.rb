Given /^I am logged in as #{capture_model}$/ do |user|
  user = model(user)
  visit path_to("the login page")
  fill_in "login", :with => user.username
  click_button "Submit"
end
