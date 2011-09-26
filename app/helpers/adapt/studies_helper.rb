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
    the_class = (ref == @active_tab) ? "active-tab" : ""
    "<li class='tab-entry'>
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
  def tabular_fields(form, attr, options = {})
    obj = form.object
    title = I18n.t("formtastic.titles.#{attr}", :default => '')
    hint = I18n.t("formtastic.hints.#{obj.class.name.underscore}.#{attr}",
                  :default => '')
    outer_options = {
      :class => (obj.is_repeatable?(attr) ? 'repeatable ' : '') + 'with-table'
    }
    outer_options[:name] = title unless title.blank?
    outer_options[:name] = options[:name] if options.has_key?(:name)
    if obj.subfields(attr).blank?
      options[:label] = outer_options[:name] unless options.has_key? :label
      outer_options.delete(:name)
    end
    
    form.inputs outer_options do
      concat(content_tag('li') do
        concat(content_tag('table') do
          concat(table_header(form, attr, options))
          concat(content_tag('tbody') do
            concat(form.fields_for("#{attr}_items".to_sym) do |f|
              concat(content_tag('tr') do
                form.object.subfields_for_nesting(attr).each do |field|
                  as = get_option(options, field, :as) ||
                           form.send(:default_input_type, field)
                  concat(content_tag('td', :class => as) do
                    input_options = field_options(form, attr, field, options)
                    concat f.input(field, input_options)
                  end)
                end
              end)
            end)
          end)
        end)
        unless hint.blank?
          concat(content_tag('p', hint, :class => 'inline-hints'))
        end
        concat(content_tag('li', form.semantic_errors(attr)))
      end)
    end
  end

  def table_header(form, attr, options = {})
    content_tag('thead') do
      concat(content_tag('tr') do
        form.object.subfields_for_nesting(attr).each do |field|
          concat(content_tag('th') do |th|
            label = get_option(options, field, :label)
            required = get_option(options, field, :required)
            concat(form.label(label || field, :required => required))
          end)
        end
      end)
    end
  end

  def field_options(form, attr, field, options = {})
    result = { :label => false }
    as = get_option(options, field, :as)
    result[:as] = as unless as.nil?
    extra_html = (options[:html_for] || {})[field] || {}
    result[:input_html] = options[:input_html].merge extra_html
    if (options[:choices_on] || []).include? field
      result[:input_html][:'data-selection-id'] =
        "#adapt-#{form.object.subfields(attr) ? field : attr}-choices"
    end
    result
  end

  def get_option(options, field, key)
    if options.has_key? key
      val = options[key]
      val.is_a?(Hash) ? (val[field] if val.has_key?(field)) : val
    end
  end
end
