require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature "Re-authentication", %q{
  In order to not have to log in separately for each application
  As a user
  I want the system to synchronise my authentication data
} do

  background do
    create_user 'Alice'
  end

  context "Alice is logged in" do
    background do
      login_as 'Alice'
    end

    scenario "Before cookie expiration, page visits work directly" do
      visit "/adapt/studies"
      path_should_be "/adapt/studies"
      page.status_code.should == 200
    end

    scenario "After cookie expiration, page visits go through redirection" do
      visit "/adapt/studies"
      path_should_be "/adapt/studies"
      page.status_code.should == 302
    end
  end
end
