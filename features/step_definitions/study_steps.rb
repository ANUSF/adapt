Given /^(.*) has a study entitled "(.*)"$/ do |user, title|
  Given "a study: \"#{title}\" exists with owner: user: \"#{user}\", " +
    "title: \"#{title}\""
end

Given /^the study "([^\"]*)" has status "([^\"]*)"$/ do |title, status|
  model("study: \"#{title}\"").update_attribute(:status, status)
end

Given /^the study "([^\"]*)" has access mode "([^\"]*)"$/ do |title, mode|
  study = model("study: \"#{title}\"")
  user = study.owner
  study.create_licence(:signed_by => user.name,
                       :email => user.email,
                       :signed_date => Date.today.strftime("%d %h %Y"),
                       :access_mode => mode)
end

Given /^the study "([^\"]*)" has an attached data file "([^\"]*)"$/ do
  |title, name|
  study = model("study: \"#{title}\"")
  content = Struct.new(:original_filename, :read).new(name, "Hello")
  a = study.attachments.create(:content => content, :category => "Data File")
end

Given /^the study "([^\"]*)" is ready for submission$/ do |title|
  Given "the study \"#{title}\" has status \"incomplete\""
  Given "the study \"#{title}\" has access mode \"A\""
  Given "the study \"#{title}\" has an attached data file \"test\""
  study = model("study: \"#{title}\"")
  study.data_kind = ["unknown"]
  study.data_is_quantitative = "1"
  study.depositors = { "name" => "me", "affiliation" => "my uni" }
  study.principal_investigators = [{ "name" => "me", "affiliation" => "my uni" }]
  study.save!
  throw "Ouch!" unless Study.find(study.id).ready_for_submission?
end

When /^I submit the study "([^\"]*)"$/ do |title|
  driver = Capybara.current_session.driver
  driver.process :post, submit_study_path(model("study: \"#{title}\""))
end
