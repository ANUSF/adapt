# Methods added to this helper will be available to all templates in the
# application.
module ApplicationHelper
  # -- make the formular_for helper method from the formular gem available
  include Formular::Helper

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
    chunks = text.split("\n").reject(&:blank?)
    sanitize(chunks.map { |p| "<p>#{p}</p>" }.join("\n"))

    #TODO RedCloth on jruby apparently choke on non-ASCII characters
    #sanitize(RedCloth.new(text).to_html).untaint
  end
end
