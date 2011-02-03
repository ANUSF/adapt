require File.expand_path('../../acceptance_helper', __FILE__)

feature "User Login", %q{
  In order to gain the appropriate access privileges for my role
  As a user
  I want to log in to the application
} do

  background do
    Adapt::User.make :role => 'contributor', :name => 'Alice'
  end

  scenario "Log in as Alice" do
    login_as 'Alice'
    page.should have_content 'Add study'
  end
end
