module NavigationHelpers
  # Put helper methods related to the paths in your application here.

  def homepage
    "/"
  end

  def study_page_for(title)
    "/adapt/studies/#{Adapt::Study.find_by_title(title).id}"
  end

  def study_edit_page_for(title)
    "/adapt/studies/#{Adapt::Study.find_by_title(title).id}/edit"
  end
end

RSpec.configuration.include NavigationHelpers, :type => :acceptance
