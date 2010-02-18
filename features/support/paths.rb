module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name
    
    when /^the homepage$/
      '/'
    
    when /^the login page$/
      '/login'

    when /^the study index page$/
      '/studies'

    when /^the study details page for "(.+)"$/
      "/studies/#{model("study: \"#{$1}\"").id}"

    when /^the licence page for "(.+)"$/
      "/studies/#{model("study: \"#{$1}\"").id}/licences"

    when /^"(.+)"$/
      $1

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
