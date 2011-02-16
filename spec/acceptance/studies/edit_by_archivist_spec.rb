require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature "Edit By Archivist", %q{
  In order to speed up the curation process
  As an archivist
  I want to use additional features when editing a study
} do

  background do
    create_user 'Alice', :role => 'archivist'
    create_study 'First Study', :owner => 'Alice'
    login_as 'Alice'
    visit study_edit_page_for 'First Study'
  end

  scenario "The skip licence checkbox works" do
    click_link 'Licence Details'
    box = 'Licence will be obtained separately'
    for action in [:check, :uncheck]
      self.send action, box
      click_button 'Apply'
      find_field(box)['checked'].should == (action == :check)
    end
  end
end
