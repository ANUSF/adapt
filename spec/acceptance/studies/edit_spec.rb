require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature "Edit", %q{
  In order to add files and metadata to my submission
  As a contributor
  I want to edit a study entry
} do

  background do
    create_user 'Alice'
    create_study 'First Study', :owner => 'Alice'
    login_as 'Alice'
    visit study_edit_page_for 'First Study'
  end

  scenario "Alice presses the 'Apply' button" do
    click_button 'Apply'
    page_heading_should_be 'Edit Study'
  end

  scenario "Date inputs are normalised automatically" do
    click_link 'Data Description'
    for input, output in [['5/85',         'May 1985'   ],
                          ['Oct 10, 1923', '10 Oct 1923'],
                          ['3.5.1965',     '03 May 1965' ]]
      fill_in 'adapt_study_period_start', :with => input
      click_button 'Apply'

      page_heading_should_be 'Edit Study'
      find_field('adapt_study_period_start').value.should == output
    end
  end

  scenario "Ambiguous or indecypherable dates are rejected" do
    click_link 'Data Description'
    for input in ['Mar 5', 'last year', '5 Okt 1973']
      fill_in 'adapt_study_period_start', :with => input
      click_button 'Apply'
      
      page.should have_content 'Invalid'
    end
  end

  scenario "The checkboxes work" do
    click_link 'Data Description'
    for box in ['Qualitative', 'Quantitative']
      for action in [:check, :uncheck]
        self.send action, box
        click_button 'Apply'
        find_field(box)['checked'].should == (action == :check)
      end
    end
  end

  scenario "The attachments list can be updated from the file store." do
    manually_upload_attachment_for 'First Study', :name => 'test.txt',
      :content => 'This is just a test.'
    check 'Update from manual uploads'
    click_button 'Apply'

    page.should have_content 'test.txt'
  end
end
