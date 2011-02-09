require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature "Handover", %q{
  In order to allow another archivist to add data files or metadata
  As an archivist
  I want to hand over a study that has been assigned to me
} do

  background do
    create_user 'Alice'
    create_user 'Bob', :role => 'archivist'
    create_user 'Celine', :role => 'archivist'
    create_user 'Dan', :role => 'admin'
    create_study 'First Study', :owner => 'Alice'

    set_study_status_for 'First Study', :to => 'submitted'
    set_archivist_for 'First Study', :to => 'Bob'
  end

  scenario "Bob as the assigned archivist hands over the study to Celine" do
    login_as 'Bob'
    visit study_page_for('First Study')
    select 'Celine', :from => 'archivist'
    click_button 'Hand over'

    there_should_be_a_notice 'handover successful'
    page.should have_content 'Archivist: Celine'
    a_handover_notification_should_be_sent_for 'First Study', :from => 'Bob'
  end

  scenario "Dan as an admin reassigns the study from Bob to Celine" do
    login_as 'Dan'
    visit study_page_for('First Study')
    select 'Celine', :from => 'archivist'
    click_button 'Hand over'

    there_should_be_a_notice 'handover successful'
    page.should have_content 'Archivist: Celine'
    a_handover_notification_should_be_sent_for 'First Study', :from => 'Bob'
  end

  scenario "Alice as the owner cannot do a study handover" do
    login_as 'Alice'
    visit study_page_for('First Study')

    page.should have_no_content 'Hand over'
  end


  def a_handover_notification_should_be_sent_for(title, options = {})
    study = Adapt::Study.find_by_title(title)
    check_study_notification(study, study.archivist.email,
                             'ADAPT: A study has been handed over to you',
                             study.title,
                             study.owner.username,
                             adapt_study_path(study),
                             "formerly assigned to #{options[:from]}")
  end
end
