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
    fill_in_creation_form :as => 'Alice',
      :title => 'My Study', :abstract => 'To be written'

    page_heading_should_be 'Edit Study'
    there_should_be_a_notice "Study entry created"
    find_field('Study title').should have_content 'My Study'
    find_field('Study abstract').should have_content 'To be written'
  end

  scenario "Alice tries to create a study with a title she's already used" do
    create_study 'My Study', :owner => 'Alice'
    fill_in_creation_form :as => 'Alice',
      :title => 'My Study', :abstract => 'To be written'

    there_should_be_an_error_message "Study creation failed"
    page.should have_content "You have another study with this title"
  end

  scenario "Alice forgets to specify a title" do
    fill_in_creation_form :as => 'Alice',
      :abstract => 'A very important result'

    page_heading_should_be "New Study"
    there_should_be_an_error_message "Study creation failed"
    page.should have_content "May not be blank"
    find_field('Study abstract').should have_content 'A very important result'
  end

  scenario "Alice forgets to write an abstract" do
    fill_in_creation_form :as => 'Alice',
      :title => 'This Study'

    page_heading_should_be "Edit Study"
    there_should_be_a_notice "Study entry created"
    page.should have_content "May not be blank"
    find_field('Study title').should have_content 'This Study'
  end
    
  scenario "Alice cancels the study creation" do
    fill_in_creation_form :as => 'Alice', :submit => 'Cancel',
      :title => 'This Study', :abstract => 'To be written'
    
    there_should_be_a_notice "Study creation cancelled"
  end
    
  scenario "Alice cancels the study creation before completing the form" do
    fill_in_creation_form :as => 'Alice', :submit => 'Cancel'
    
    there_should_be_a_notice "Study creation cancelled"
  end
    
  scenario "One cannot create a study without loggin in" do
    click_link 'Add study'
    
    there_should_be_an_error_message "Must be logged in"
  end

  scenario "Archivists can create and edit studies" do
    create_user 'Bill', :role => 'archivist'
    fill_in_creation_form :as => 'Bill',
      :title => 'My Study', :abstract => 'To be written'

    page_heading_should_be 'Edit Study'
    there_should_be_a_notice "Study entry created"
    find_field('Study title').should have_content 'My Study'
    find_field('Study abstract').should have_content 'To be written'
  end


  def fill_in_creation_form(options = {})
    login_as options[:as] if options[:as]
    click_link 'Add study'
    fill_in 'Study title', :with => options[:title] || ''
    fill_in 'Study abstract', :with => options[:abstract] || ''
    click_button options[:submit] || 'Save'
  end
end
