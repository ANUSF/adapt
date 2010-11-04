ASSDA_EMAIL = 'assda@anu.edu.au'

def check_study_notification(study, recipient, subject, *body_patterns)
  email = ActionMailer::Base.deliveries.first
  email.should_not be_nil
  email.from.should    == [ASSDA_EMAIL]
  email.to.should      == [recipient]
  email.subject.should == subject
  body_patterns.each { |pattern| email.body.should include(pattern) }
end

Then /^a submission notification for "([^\"]*)" should be sent$/ do |title|
  study = model("adapt_study: \"#{title}\"")
  check_study_notification(study, ASSDA_EMAIL,
                           'ADAPT: A new study was submitted',
                           study.title,
                           study.owner.username,
                           adapt_study_path(study))
end
