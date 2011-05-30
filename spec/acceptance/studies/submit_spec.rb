require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature "Submit", %q{
  In order to finalise a study deposit and understand ADA policies
  As a contributor
  I want to submit the study entry and be presented a licence form
} do

  background do
    create_user 'Alice'
    create_study 'First Study', :owner => 'Alice'
    login_as 'Alice'
  end

  scenario "Alice submits a complete study and is shown the licence form" do
    prepare_study_for_submission 'First Study'
    visit study_edit_page_for 'First Study'
    click_button 'Submit this study'

    page_heading_should_be 'Deposit Licence'
    there_should_be_a_notice 'Please review and confirm'
    page.should have_content 'Signed: Alice'
    there_should_be_a_button 'Accept'
  end

  scenario "Alice submits an incomplete study" do
    visit study_edit_page_for 'First Study'
    click_button 'Submit this study'

    page_heading_should_be 'Edit Study'
    there_should_be_an_error_message 'not yet ready for submission'
  end

  scenario "Alice submits a study that's been tagged as submitted" do
    set_study_status_for 'First Study', :to => 'submitted'
    submit_study 'First Study'

    page_heading_should_be 'Study Summary'
    there_should_be_an_error_message 'study has already been submitted'
  end

  scenario "Alice accepts the licence" do
    prepare_study_for_submission 'First Study'
    visit study_edit_page_for 'First Study'
    click_button 'Submit this study'
    click_button 'Accept'

    page_heading_should_be 'Study Summary'
    there_should_be_a_notice 'Study submitted and pending approval'
  end

  scenario "Alice declines the licence" do
    prepare_study_for_submission 'First Study'
    visit study_edit_page_for 'First Study'
    click_button 'Submit this study'
    click_button 'Cancel'

    page_heading_should_be 'Edit Study'
    there_should_be_a_notice 'submission has been cancelled'
  end

  scenario "Alice makes last minute changes before pressing 'Submit'" do
    prepare_study_for_submission 'First Study'
    visit study_edit_page_for 'First Study'
    click_link 'Title and Abstract'
    fill_in 'Study abstract', :with => 'Gallia est omnis divisa in partes tres'
    click_button 'Submit this study'
    click_button 'Accept'

    page_heading_should_be 'Study Summary'
    there_should_be_a_notice 'Study submitted and pending approval'
    page.should have_content 'Gallia est omnis'
  end


  def prepare_study_for_submission(title)
    # find the study
    study = Adapt::Study.find_by_title(title)

    # set the status
    study.status = 'incomplete'

    # create a licence
    owner = study.owner
    study.create_licence(:signed_by => owner.name,
                         :email => owner.email,
                         :signed_date => Date.today.strftime("%d %h %Y"),
                         :access_mode => 'A')

    # create an attachments
    content = Struct.new(:original_filename, :read).new('Test', "Hello")
    study.attachments.create(:content => content, :category => "Data File")

    # fill in required attributes
    study.data_kind = ["unknown"]
    study.data_is_quantitative = "1"
    study.depositors = { "name" => "me", "affiliation" => "my uni" }
    study.principal_investigators = [{ "name" => "me", "affiliation" => "uni" }]

    # save
    study.save!
  end

  def submit_study(title)
    study = Adapt::Study.find_by_title(title)
    Capybara.current_session.driver.process(:post,
                                            submit_adapt_study_path(study))
  end
end
