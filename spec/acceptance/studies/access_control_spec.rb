require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature "Access Control", %q{
  In order to prevent confusion and sabotage
  As a contributor
  I want to have exclusive edits to submissions I am working on
} do

  background do
    create_user 'Alice'
    create_user 'Bob'
    create_study 'First Study', :owner => 'Alice'
    login_as 'Bob'
  end

  scenario "Bob cannot view a study of Alice's" do
    visit study_page_for('First Study')
    page.should have_no_content 'Study Summary'
    page.should have_content 'Access denied'
  end

  scenario "Bob cannot edit a study of Alice's" do
    visit study_edit_page_for('First Study')
    page.should have_no_content 'Edit Study'
    page.should have_content 'Access denied'
  end
end
