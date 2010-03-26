class Upload < StringIO
  attr_reader :original_filename, :content_type

  def initialize(name, data, type)
    @original_filename = name
    @content_type = type
    super(data)
  end
end

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
  a = study.attachments.create(:content => Upload.new("test", "Hello!", "text"),
                               :category => "Data File")
end

Given /^the study "([^\"]*)" is ready for submission$/ do |title|
  Given "the study \"#{title}\" has status \"unsubmitted\""
  Given "the study \"#{title}\" has access mode \"A\""
  Given "the study \"#{title}\" has an attached data file \"test\""
  study = model("study: \"#{title}\"")
  study.update_attribute :data_kind, "unknown"
  study.update_attribute :depositors,
                         { "name" => "me", "affiliation" => "my uni" }
  study.update_attribute :principal_investigators,
                         [{ "name" => "me", "affiliation" => "my uni" }]
end

When /^I submit the study "([^\"]*)"$/ do |title|
  visit submit_study_path(model("study: \"#{title}\"")), :post
end
