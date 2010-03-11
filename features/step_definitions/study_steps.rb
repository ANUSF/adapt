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
                       :signed_date => Date.today.inspect,
                       :access_mode => mode)
end

When /^I submit the study "([^\"]*)"$/ do |title|
  visit submit_study_path(model("study: \"#{title}\"")), :post
end
