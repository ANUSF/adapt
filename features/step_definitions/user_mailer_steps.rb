ASSDA_EMAIL = 'assda@anu.edu.au'

Then /^a submission notification for "([^\"]*)" should be sent$/ do |title|
  study = model("adapt_study: \"#{title}\"")
  email = ActionMailer::Base.deliveries.first
  email.should_not be_nil
  email.from.should    == [ASSDA_EMAIL]
  email.to.should      == [ASSDA_EMAIL]
  email.subject.should == 'ADAPT: A new study was submitted'
  email.body.should == "Kilroy was here"
end
