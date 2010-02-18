Given /^(.*) has a study entitled "(.*)"$/ do |user, title|
  Given "a study: \"#{title}\" exists with owner: user: \"#{user}\", " +
    "title: \"#{title}\""
end

Given /^the study "([^\"]*)" has status "([^\"]*)"$/ do |title, status|
  model("study: \"#{title}\"").update_attribute(:status, status)
end

When /^I submit the study "([^\"]*)"$/ do |title|
  visit new_study_licence_path(model("study: \"#{title}\""))
end
