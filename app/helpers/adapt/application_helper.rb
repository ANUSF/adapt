# Methods added to this helper will be available to all templates in the
# application.
module Adapt::ApplicationHelper
  # -- make the formular_for helper method from the formular gem available
  include Formular::Helper

  # Trims strings longer than the given size.
  def clip_text(text, size)
    if text.length > size then text[0, size-5] + "[...]" else text end
  end

  # Does normal html encoding plus replaces blank text with a default value.
  def cleanup(text, default = "&mdash;".html_safe)
    text.blank? ? default : h(text)
  end

  # Translates some formatting into HTML
  def format_text(text)
    #TODO We'd like to do something more extensive like this:
    #
    #     sanitize(RedCloth.new(text).to_html)
    #
    # (but RedCloth on jruby apparently chokes on non-ASCII characters)

    chunks = text.split("\n").reject(&:blank?)
    sanitize(chunks.map { |p| "<p>#{p}</p>" }.join("\n"))
  end
end
