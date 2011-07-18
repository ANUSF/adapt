require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature "List", %q{
  In order to clean up partial deposits that did not get finished
  As a contributor
  I want to remove unsubmitted deposits.
} do

  background do
    create_user 'Alice'
    create_user 'Bill'
    create_study 'First Study',  :owner => 'Alice'
    create_study 'Second Study', :owner => 'Alice'
    create_study 'Advanced Ham', :owner => 'Bill'
  end

  scenario "Alice can delete her deposits" do
    login_as 'Alice'
    click_link 'View deposits'
    click_link 'Delete'

    page_heading_should_be 'Deposits'
    page.should have_content 'Successfully destroyed study'
    page.should have_no_content 'First Study'
    page.should have_content 'Second Study'
  end
end
