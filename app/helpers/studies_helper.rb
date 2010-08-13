module StudiesHelper
  def date(date_string)
    begin PartialDate.new(date_string) rescue nil end.to_s
  end

  def each(list, &block)
    (list.blank? ? [] : list).each &block
  end

  def access_text(study)
    if study.licence.nil? or study.licence.access_mode.blank?
      nil
    else
      "#{study.licence.access_mode} (#{study.licence.access_phrase})"
    end
  end

  def tab_link(ref, text)
    the_class = (ref == @active_tab) ? "current-tab" : ""
    "<li class='tab-entry'>
       <a href='#{ref}' class='#{the_class}'>
         <span>#{text}</span>
       </a>
     </li>"
  end

  # Preserves paragraph breaks in Nesstar Publisher
  def format_for_Nesstar(text)
    chunks = sanitize(text).split("\n").reject(&:blank?)
    chunks.join("\n<![CDATA[\n]]><![CDATA[\n]]>\n").html_safe
  end
end
