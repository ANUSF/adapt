Then /^a submission notification for "([^\"]*)" should be sent$/ do |title|
  study = model("adapt_study: \"#{title}\"")
  email = ActionMailer::Base.deliveries.first
  email.should_not be_nil
end
