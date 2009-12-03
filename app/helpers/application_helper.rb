# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  FORM_BUILDER = SimpleFormBuilder
  
  def make_form_for(name, *args, &block)
    options = args.last.is_a?(Hash) ? args.pop : {}
    args = (args << options.merge(:builder => FORM_BUILDER))
    form_for(name, *args, &block)
  end

  def clip_text(text, size)
    if text.length > size then text[0, size-5] + "[...]" else text end
  end

  def cleanup(text, default = "&mdash;")
    text.blank? ? default : h(text)
  end
end
