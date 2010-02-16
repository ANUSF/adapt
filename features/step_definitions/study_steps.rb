Given /^(.*) has a study entitled "(.*)"$/ do |user, title|
  Given "a study: \"#{title}\" exists with owner: user: \"#{user}\", " +
    "title: \"#{title}\""
end

Given /^the study "([^\"]*)" has status "([^\"]*)"$/ do |title, status|
  study = model("study: \"#{title}\"")
  study.update_attribute(:status, status)
end

When /^I submit the study "([^\"]*)"$/ do |title|
  study = model("study: \"#{title}\"")
  visit "/studies/#{study.id}/submit", :post
end
