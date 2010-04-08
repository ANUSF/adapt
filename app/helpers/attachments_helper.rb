module AttachmentsHelper
  def format_attachment(attachment)
    link = link_to h(attachment.name), download_attachment_path(attachment)
    format_text(attachment.description).sub(/<p>/, "<p>#{link} &mdash; ")
  end
end
