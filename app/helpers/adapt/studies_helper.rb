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

  def get_option(options, field, key)
    if options.has_key? key
      val = options[key]
      val.is_a?(Hash) ? (val[field] if val.has_key?(field)) : val
    end
  end

  # Takes care of formtastic markup for repeatable and/or composite attributes
  def tabular_fields(form, attr, options = {})
    obj = form.object
    outer_options = { :class => obj.is_repeatable?(attr) ? 'repeatable' : '' }
    title = I18n.t("formtastic.titles.#{attr}", :default => '')
    outer_options[:name] = title unless title.blank?
    outer_options[:name] = options[:name] if options.has_key?(:name)
    if obj.subfields(attr).blank?
      options[:label] = outer_options[:name] unless options.has_key? :label
      outer_options.delete(:name)
    end
    fields_with_choices = options.delete(:choices_on) || []
    
    form.inputs outer_options do
      concat(content_tag('li') do
        concat(content_tag('table') do
          concat(content_tag('thead') do
            concat(content_tag('tr') do
              obj.subfields_for_nesting(attr).each do |field|
                concat(content_tag('th') do |th|
                  concat(form.label(get_option(options, field, :label) || field))
                end)
              end
            end)
          end)
          concat(content_tag('tbody') do
            concat(form.fields_for("#{attr}_items".to_sym) do |f|
              concat(content_tag('tr') do
                obj.subfields_for_nesting(attr).each do |field|
                  input_options = { :label => false }
                  as = get_option(options, field, :as)
                  input_options[:as] = as unless as.nil?
                  extra_html = (options[:html_for] || {})[field] || {}
                  input_options[:input_html] =
                      options[:input_html].merge extra_html
                  if fields_with_choices.include? field
                    input_options[:input_html][:'data-selection-id'] =
                      "#adapt-#{obj.subfields(attr) ? field : attr}-choices"
                  end
                  concat(content_tag('td', :class => as) do
                    concat f.input(field, input_options)
                  end)
                end
              end)
            end)
          end)
        end)
        hint = I18n.t("formtastic.hints.#{obj.class.name.underscore}.#{attr}",
                      :default => '')
        unless hint.blank?
          concat(content_tag('p', hint, :class => 'inline-hints'))
        end
        concat(content_tag('li', form.errors_on(attr)))
      end)
    end
  end

  # Takes care of formtastic markup for repeatable and/or composite attributes
  def nested_fields(form, attr, options = {})
    obj = form.object
    outer_options = { :class => obj.is_repeatable?(attr) ? 'repeatable' : '' }
    title = I18n.t("formtastic.titles.#{attr}", :default => '')
    outer_options[:name] = title unless title.blank?
    outer_options[:name] = options[:name] if options.has_key?(:name)
    if obj.subfields(attr).blank?
      options[:label] = outer_options[:name] unless options.has_key? :label
      outer_options.delete(:name)
    end
    fields_with_choices = options.delete(:choices_on) || []
    
    form.inputs outer_options do
      concat(form.semantic_fields_for(:"#{attr}_items") do |f|
        concat(f.inputs(:class => 'tabular') do
          obj.subfields_for_nesting(attr).each do |field|
            input_options = {}
            input_options[:hint] =
              I18n.t("formtastic.hints.#{obj.class.name.underscore}.#{attr}",
                     :default => '')
            for key in [:label, :required, :as] do
              if options.has_key? key
                val = options[key]
                input_options[key] =
                  val.is_a?(Hash) ? (val[field] if val.has_key?(field)) : val
              end
            end
            extra_html = (options[:html_for] || {})[field] || {}
            input_options[:input_html] = options[:input_html].merge extra_html
            if fields_with_choices.include? field
              input_options[:input_html][:'data-selection-id'] =
                "#adapt-#{obj.subfields(attr) ? field : attr}-choices"
            end
            concat f.input(field, input_options)
          end
        end)
      end)
      concat(content_tag('li', form.errors_on(attr)))
    end
  end
end
