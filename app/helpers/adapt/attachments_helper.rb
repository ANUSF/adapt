module Adapt::AttachmentsHelper
  def format_attachment(attachment)
    link = link_to h(attachment.name), download_adapt_attachment_path(attachment)
    t = if attachment.description.blank?
          "<p>#{link} <em>(no description)</em></p>".html_safe
        else
          format_text(attachment.description).sub(/<p>/, "<p>#{link} &mdash; ")
        end
    t.html_safe
  end
end
