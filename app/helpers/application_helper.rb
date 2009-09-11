# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  FORM_BUILDER = SimpleFormBuilder
  
  def make_form_for(name, *args, &block)
    options = args.last.is_a?(Hash) ? args.pop : {}
    args = (args << options.merge(:builder => FORM_BUILDER))
    form_for(name, *args, &block)
  end
end
