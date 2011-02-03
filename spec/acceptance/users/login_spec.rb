require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature "User Login", %q{
  In order to gain the appropriate access privileges for my role
  As a user
  I want to log in to the application
} do

  background do
    create_user 'Alice'
  end

  scenario "Log in as Alice" do
    login_as 'Alice'
    page.should have_content 'Add study'
  end
end
