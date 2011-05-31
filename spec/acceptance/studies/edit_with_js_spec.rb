require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature "Edit With Js", %q{
  In order to save time and keystrokes and get better feedback
  As a contributor
  I want the study edit page to respond dynamically to my inputs
}, :js => true do

  background do
    create_user 'Alice'
    create_study 'First Study', :owner => 'Alice'
    login_as 'Alice'
    visit study_edit_page_for 'First Study'
  end

  scenario "Dummy to work around strange problems on first access" do
  end

  scenario "Edits are saved when a new tab is selected" do
    click_link 'Data Description'
    fill_in 'Response rate:', :with => '90%'
    click_link 'Credits'

    there_should_be_a_notice 'Changes were saved'
    find_field('Response rate:').value.should == '90%'
  end

  scenario "Nothing is saved on tab change if there were no edits" do
    click_link 'Data Description'
    click_link 'Credits'
    page.should have_no_content 'Changes were saved'
  end

  scenario "Alice selects a file to attach" do
    click_link 'Attached Files'
    attach_file 'Upload', '/home/olaf/vapour.c'
    page.should have_content 'vapour.c'
  end

  scenario "Alice selects multiple files to attach", :js_advanced => true do
    click_link 'Attached Files'
    attach_file 'Upload', '/home/olaf/vapour.c'
    attach_file 'Upload', '/home/olaf/warez.c'
    page.should have_content 'vapour.c'
    page.should have_content 'warez.c'
  end

  scenario "Alice sees tool tips appear for some fields", :js_advanced => true do
    click_link 'Data Description'
    find_field('Related data').trigger(:mouseover)
    sleep 2
    page.should have_css "#adapt-tooltip", :content => "If this study is related"
  end
end
