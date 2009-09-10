Then /^I should not be on (.+)$/ do |page_name|
  URI.parse(current_url).path.should_not == path_to(page_name)
end
