# Methods added to this helper will be available to all templates in the
# application.
module ApplicationHelper
  # Helper method for creating forms using our own custom form builder
  def make_form_for(name, *args, &block)
    # -- modify the arguments so that our form builder is specified
    options = args.last.is_a?(Hash) ? args.pop : {}
    args = (args << options.merge(:builder => SimpleFormBuilder))

    # -- now call the standard form_for helper
    form_for(name, *args, &block)
  end

  # Trims strings longer than the given size.
  def clip_text(text, size)
    if text.length > size then text[0, size-5] + "[...]" else text end
  end

  # Does normal html encoding plus replaces blank text with a default value.
  def cleanup(text, default = "&mdash;")
    text.blank? ? default : h(text)
  end

  # Formats text using the RedCloth markup engine, then sanitizes.
  def format_text(text)
    sanitize(RedCloth.new(text).to_html).untaint
  end
end
