module Adapt::AttachmentsHelper
  def format_attachment(attachment)
    extra =
      link_to(h(attachment.name), download_adapt_attachment_path(attachment)) +
      (attachment.restricted? ? ' <em>(restricted)</em>'.html_safe : '')
    t = if attachment.description.blank?
          "<p>#{extra} &mdash;  <em>(no description)</em></p>"
        else
          format_text(attachment.description).sub(/<p>/, "<p>#{extra} &mdash; ")
        end
    t.html_safe
  end
end
