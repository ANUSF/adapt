ASSDA_EMAIL = 'assda@anu.edu.au'

def check_study_notification(study, recipient, subject, *body_patterns)
  email = ActionMailer::Base.deliveries.first
  email.should_not be_nil
  email.from.should    == [ASSDA_EMAIL]
  email.to.should      == [recipient]
  email.subject.should == subject
  body_patterns.each { |pattern| email.body.should include(pattern) }
end

Then /^no mail should be sent$/ do
  ActionMailer::Base.deliveries.should be_empty
end

Then /^a submission notification for "([^\"]*)" should be sent$/ do |title|
  study = Adapt::Study.find_by_title(title)
  check_study_notification(study, ASSDA_EMAIL,
                           'ADAPT: A new study has been submitted',
                           study.title,
                           study.owner.username,
                           adapt_study_path(study))
end

Then /^an archivist notification for "([^\"]*)" should be sent$/ do |title|
  study = Adapt::Study.find_by_title(title)
  check_study_notification(study, study.archivist.email,
                           'ADAPT: A new study has been assigned to you',
                           study.title,
                           study.owner.username,
                           adapt_study_path(study))
end

Then /^a notification that "([^\"]*)" handed over "([^\"]*)" should be sent$/ do
  |user, title|
  study = Adapt::Study.find_by_title(title)
  check_study_notification(study, study.archivist.email,
                           'ADAPT: A study has been handed over to you',
                           study.title,
                           study.owner.username,
                           adapt_study_path(study),
                           "has been handed over to you by #{user}")
end

Then /^an approval notification for "([^\"]*)" should be sent$/ do |title|
  study = Adapt::Study.find_by_title(title)
  check_study_notification(study, study.owner.email,
                           'Your submission via ADAPT has been approved',
                           study.title,
                           study.owner.name,
                           study.identifier)
end
