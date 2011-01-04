def column_contents(name)
  t = tableish("table tr", "th,td")
  (t.transpose)[t[0].index(name)].join('"')
end

When /^(?:|I )click on "([^"]*)"(?: within "([^"]*)")?$/ do |field, selector|
  with_scope(selector) do
    find_field(field).trigger('focus')
  end
end

When /^(?:|I )hover on "([^\"]*)"$/ do |selector|
  page.find(:css, selector).trigger(:mouseover)
end

When /^(?:|I )pause for ([\d]+) second(?:s)$/ do |seconds|
  sleep(seconds.to_i)
end

Then /^(?:|I )should not be on (.+)$/ do |page_name|
  URI.parse(current_url).path.should_not == path_to(page_name)
end

Then /^(?:|I )should see (?:a|an) "([^\"]*)" link$/ do |text|
  page.should have_css("a[href]", :content => text)
end

Then /^(?:|I )should not see (?:a|an) "([^\"]*)" link$/ do |text|
  page.should have_no_css("a[href]", :content => text)
end

Then /^(?:|I )should see (?:a|an) "([^\"]*)" button$/ do |text|
  page.should have_css("input[value=\"#{text}\"]")
end

Then /^(?:|I )should not see (?:a|an) "([^\"]*)" button$/ do |text|
  page.should have_no_css("input[value=\"#{text}\"]")
end

Then /^(?:|I )should see (?:a|an|the) page heading (.*)$/ do |pattern|
  Then "I should see #{pattern} within \"#content > h1, article > h1\""
end

Then /^(?:|I )should see (?:a|an|the) error message (.*)$/ do |pattern|
  Then "I should see #{pattern} within \"#flash_error, .flash-error\""
end

Then /^(?:|I )should see (?:a|the) notice (.*)$/ do |pattern|
  Then "I should see #{pattern} within \"#flash_notice, .flash-notice\""
end

Then /^(?:|I )should see a table with (\d+) row(?:s?)$/ do |n|
  page.should have_css("table tbody tr", :count => n.to_i)
end

Then /^(?:|I )should see "([^\"]*)" in the "([^\"]*)" column$/ do
  |text, col|
  column_contents(col).should include(text)
end

Then /^(?:|I )should see \/([^\"\/]*)\/ in the "([^\"]*)" column$/ do
  |regexp, col|
  column_contents(col).should include(Regexp.new(regexp))
end

Then /^(?:|I )should not see "([^\"]*)" in the "([^\"]*)" column$/ do
  |text, col|
  column_contents(col).should_not include(text)
end

Then /^(?:|I )should not see \/([^\"\/]*)\/ in the "([^\"]*)" column$/ do
  |regexp, col|
  column_contents(col).should_not include(Regexp.new(regexp))
end

Then /^the "([^\"]*)" field(?: within "([^\"]*)")? should be empty$/ do
  |field, selector|
  with_scope(selector) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    if field_value.respond_to? :should
      field_value.should_not =~ /.+/
    else
      assert_no_match(/.+/, field_value)
    end
  end
end

Then /^there should be no "([^\"]*)" field(?: within "([^\"]*)")?$/ do
  |field, selector|
  page.should have_no_selector([selector, "##{field}"].compact.join(' '))
end

Then /^show me the content of "([^\"]*)"$/ do |selector|
  puts "\n!!! \"#{selector}\" has content \"#{find(selector).text}\" !!!"
end
