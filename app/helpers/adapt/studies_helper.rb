module Adapt::StudiesHelper
  def date(date_string)
    begin Adapt::PartialDate.new(date_string) rescue nil end.to_s
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
    the_class = (ref == @active_tab) ? " active-tab" : ""
    "<li>
       <a href='#{ref}' class='#{the_class}'>
         <span>#{text}</span>
       </a>
     </li>".html_safe
  end

  # Preserves paragraph breaks in Nesstar Publisher
  def format_for_Nesstar(text)
    chunks = sanitize(text).split("\n").reject(&:blank?)
    chunks.join("\n<![CDATA[\n]]><![CDATA[\n]]>\n").html_safe
  end

  # Takes care of formtastic markup for repeatable and/or composite attributes
  def nested_fields(form, attr, options = {})
    obj = form.object
    outer_options = { :class => obj.is_repeatable?(attr) ? 'repeatable' : '' }
    outer_options[:name] = options[:name] if options.has_key?(:name)
    
    form.inputs outer_options do
      concat(form.semantic_fields_for(:"#{attr}_items") do |f|
        concat(f.inputs(:class => 'tabular') do
          obj.subfields_for_nesting(attr).each do |field|
            input_options = {}
            for key in [:label, :required, :as] do
              if options.has_key? key
                val = options[key]
                input_options[key] =
                  val.is_a?(Hash) ? (val[field] if val.has_key?(field)) : val
              end
            end
            input_options[:input_html] = options[:input_html]
            concat f.input(field, input_options)
          end
        end)
      end)
      concat(content_tag('li', form.errors_on(attr)))
    end
  end
end
