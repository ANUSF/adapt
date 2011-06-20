# Methods added to this helper will be available to all templates in the
# application.
module Adapt::ApplicationHelper
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
    #TODO This did not work with jruby, but should now in production:
    #
    #     sanitize(RedCloth.new(text).to_html)

    chunks = text.split("\n").reject(&:blank?)
    sanitize(chunks.map { |p| "<p>#{p}</p>" }.join("\n"))
  end
end
