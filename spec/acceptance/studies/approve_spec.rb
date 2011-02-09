require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature "Approve", %q{
  In order to manage workloads and the placement of material
  As a manager
  I want to approve studies and assign them to archivists
} do

  background do
    create_user 'Alice'
    create_user 'Bob', :role => 'admin'
    create_user 'Celine', :role => 'archivist'
    create_study 'First Study', :owner => 'Alice'
    login_as 'Bob'
  end

  scenario "Bob can see submitted studies" do
    set_study_status_for 'First Study', :to => 'submitted'
    visit adapt_studies_path

    column_contents('Title').should include('First Study')
    column_contents('Status').should include('submitted')
  end

  scenario "Bob cannot see unsubmitted studies" do
    set_study_status_for 'First Study', :to => 'incomplete'
    visit adapt_studies_path

    column_contents('Title').should_not include('First Study')
  end

  scenario "Bob can approve submitted studies" do
    set_study_status_for 'First Study', :to => 'submitted'
    visit study_page_for('First Study')
    select 'Celine', :from => 'Archivist'
    click_button 'Approve'

    page.should have_content 'approved'
    an_archivist_notification_should_be_sent_for 'First Study'
  end

  scenario "Bob cannot approve unsubmitted studies" do
    set_study_status_for 'First Study', :to => 'incomplete'
    visit study_page_for('First Study')

    page.should have_no_content 'Approve'
  end


  def an_archivist_notification_should_be_sent_for(title)
    study = Adapt::Study.find_by_title(title)
    check_study_notification(study, study.archivist.email,
                             'ADAPT: A new study has been assigned to you',
                             study.title,
                             study.owner.username,
                             adapt_study_path(study))
  end
end
