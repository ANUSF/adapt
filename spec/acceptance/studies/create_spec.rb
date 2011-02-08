require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature "List", %q{
  In order to start preparing for a data submission
  As a contributor
  I want to create a study entry
} do

  background do
    create_user 'Alice'
  end

  scenario "Alice successfully creates a study" do
    login_as 'Alice'
    fill_in_creation_form :title => 'My Study', :abstract => 'To be written'

    page_heading_should_be 'Edit Study'
    there_should_be_a_notice "Study entry created"
    find_field('Study title').should have_content 'My Study'
    find_field('Study abstract').should have_content 'To be written'
  end

  scenario "Alice tries to create a study with a title she's already used" do
    create_study 'My Study', :owner => 'Alice'
    login_as 'Alice'
    fill_in_creation_form :title => 'My Study', :abstract => 'To be written'

    there_should_be_an_error_message "Study creation failed"
    page.should have_content "You have another study with this title"
  end

  scenario "Alice forgets to specify a title" do
    login_as 'Alice'
    fill_in_creation_form :abstract => 'A very important result'

    page_heading_should_be "New Study"
    there_should_be_an_error_message "Study creation failed"
    page.should have_content "May not be blank"
    find_field('Study abstract').should have_content 'A very important result'
  end

  scenario "Alice forgets to write an abstract" do
    login_as 'Alice'
    fill_in_creation_form :title => 'This Study'

    page_heading_should_be "Edit Study"
    there_should_be_a_notice "Study entry created"
    page.should have_content "May not be blank"
    find_field('Study title').should have_content 'This Study'
  end
    

  def fill_in_creation_form(options = {})
    click_link 'Add study'
    fill_in 'Study title', :with => options[:title] || ''
    fill_in 'Study abstract', :with => options[:abstract] || ''
    click_button options[:finish_with] || 'Save'
  end
end
