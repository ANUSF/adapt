require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature "Store", %q{
  In order to create regular files that I can access from my workstation
  As an archivist
  I want to store studies that has been submitted and approved
} do

  background do
    create_user 'Alice'
    create_user 'Bob', :role => 'admin'
    create_user 'Celine', :role => 'archivist'
    create_study 'First Study', :owner => 'Alice'
    login_as 'Celine'
  end

  scenario "Celine can see studies assigned to her" do
    set_study_status_for 'First Study', :to => 'approved'
    set_archivist_for 'First Study', :to => 'Celine'
    visit adapt_studies_path

    column_contents('Title').should include 'First Study'
    column_contents('Status').should include 'approved'
    column_contents('Archivist').should include 'Celine'
  end

  scenario "Celine cannot see studies assigned to someone else" do
    set_study_status_for 'First Study', :to => 'approved'
    set_archivist_for 'First Study', :to => 'Bob'
    visit adapt_studies_path

    column_contents('Title').should_not include 'First Study'
  end

  scenario "Celine cannot see unapproved studies" do
    set_study_status_for 'First Study', :to => 'submitted'
    visit adapt_studies_path

    column_contents('Title').should_not include 'First Study'
  end

  scenario "Celine can store a study with a special test id" do
    set_study_status_for 'First Study', :to => 'approved'
    set_archivist_for 'First Study', :to => 'Celine'
    visit study_page_for 'First Study'
    select 'Test only', :from => 'range'
    click_button 'Store'

    there_should_be_a_notice 'stored'
    page.should have_content 'test99000'
    no_mail_should_be_sent
  end

  scenario "Celine can store a study with a permanent id" do
    set_study_status_for 'First Study', :to => 'approved'
    set_archivist_for 'First Study', :to => 'Celine'
    visit study_page_for 'First Study'
    select '30000-39999', :from => 'range'
    click_button 'Store'

    there_should_be_a_notice 'stored'
    page.should have_content '30000'
    an_approval_notification_should_be_sent_for 'First Study'
  end


  def no_mail_should_be_sent
    ActionMailer::Base.deliveries.should be_empty
  end

  def an_approval_notification_should_be_sent_for(title)
    study = Adapt::Study.find_by_title(title)
    check_study_notification(study, study.owner.email,
                             'Your submission via ADAPT has been approved',
                             study.title,
                             study.owner.name,
                             study.identifier)
  end
end
