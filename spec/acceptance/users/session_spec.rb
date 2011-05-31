require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature "User Login", %q{
  In order to gain the appropriate access privileges for my role
  As a user
  I want to log in to the application
} do

  background do
    create_user 'Alice'
    create_user 'Bob', :role => 'admin'
  end

  scenario "Alice has the contributor role" do
    User.find_by_name('Alice').role.should == 'contributor'
  end

  scenario "Log in as Alice" do
    login_as 'Alice'
    page.should have_content 'Add study'
    page.should have_content 'Name: Alice'
    page.should have_content 'Role: contributor'
  end

  scenario "Bob has the admin role" do
    User.find_by_name('Bob').role.should == 'admin'
    User.find_by_name('Bob').should be_admin
  end

  scenario "Log in as Bob" do
    login_as 'Bob'
    page.should have_content 'Add study'
    page.should have_content 'Name: Bob'
    page.should have_content 'Role: admin'
  end
end

feature "User Logout", %q{
  In order to prevent unauthorized access
  As a user
  I want to log out when I am done
} do

  background do
    create_user 'Alice'
    login_as 'Alice'
  end

  scenario "Alice logs out" do
    visit '/logout'
    page.should have_content 'Signed out'
  end

  scenario "Logging out a second time does nothing" do
    visit '/logout'
    visit '/logout'
    page.should have_no_content 'Signed out'
  end
end
