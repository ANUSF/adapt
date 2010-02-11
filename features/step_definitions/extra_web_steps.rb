def column_contents(name)
  t = tableish("table tr", "th,td")
  (t.transpose)[t[0].index(name)].join('"')
end

Then /^(?:|I )should not be on (.+)$/ do |page_name|
  URI.parse(current_url).path.should_not == path_to(page_name)
end

Then /^(?:|I )should see a "([^\"]*)" link$/ do |text|
  response.should have_selector("a[href]", :content => text)
end

Then /^(?:|I )should not see a "([^\"]*)" link$/ do |text|
  response.should_not have_selector("a[href]", :content => text)
end

Then /^(?:|I )should see (?:a|the) title (.*)$/ do |pattern|
  Then "I should see #{pattern} within \"#content > h1\""
end

Then /^(?:|I )should see (?:a|the) error message (.*)$/ do |pattern|
  Then "I should see #{pattern} within \"#flash_error\""
end

Then /^(?:|I )should see a table with (\d+) row(?:s?)$/ do |n|
  response.should have_selector("table tbody tr", :count => n.to_i)
end

Then /^(?:|I )should see "([^\"]*)" in the "([^\"]*)" column$/ do
  |text, col|
  column_contents(col).should contain(text)
end

Then /^(?:|I )should see \/([^\"\/]*)\/ in the "([^\"]*)" column$/ do
  |regexp, col|
  column_contents(col).should contain(Regexp.new(regexp))
end

Then /^(?:|I )should not see "([^\"]*)" in the "([^\"]*)" column$/ do
  |text, col|
  column_contents(col).should_not contain(text)
end

Then /^(?:|I )should not see \/([^\"\/]*)\/ in the "([^\"]*)" column$/ do
  |regexp, col|
  column_contents(col).should_not contain(Regexp.new(regexp))
end
