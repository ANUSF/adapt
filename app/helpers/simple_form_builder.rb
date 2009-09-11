class SimpleFormBuilder < ActionView::Helpers::FormBuilder
  def self.create_tagged_field(name, default_options = {})
    define_method(name) do |column, *args|
      options = default_options.merge(args.last.is_a?(Hash) ? args.pop : {})
      label = options.delete(:label) || column
      title = options.delete(:title) || if @object.respond_to? :help_on
                                          @object.help_on column
                                        end
      args = args + [options] unless options.empty?
      
      content =
        @template.content_tag("label", label.to_s.humanize + ":" +
                              indicate_required(options),
                              :for => "#{@object_name}_#{column}") +
        @template.content_tag("br") +
        @template.content_tag("span", super(column, *args), :class => "input")
     
      msg = error_message_on(@object_name, column)
      content += @template.content_tag("span", msg) unless msg.blank?
      @template.content_tag("p", content, :title => title)
    end

    define_method("#{name}_tag") do |column, *args|
      options = default_options.merge(args.last.is_a?(Hash) ? args.pop : {})
      label = options.delete(:label) || column
      title = options.delete(:title)
      args = args + [options] unless options.empty?
      @template.content_tag("p",
        @template.content_tag("label",
                              label.to_s.humanize + ":" +
                              indicate_required(options),
                              :for => "#{column}") +
        @template.content_tag("span",
                              self.class.send("#{name}_tag", column, "", *args),
                              :class => "input"),
        :title => title)
    end
  end

  extend ActionView::Helpers::TagHelper
  extend ActionView::Helpers::FormTagHelper

  for name in field_helpers - ["text_area", "hidden_field"]
    create_tagged_field(name, :size => 60)
  end
  
  create_tagged_field("date_select")
  create_tagged_field("datetime_select")
  create_tagged_field("select")
  create_tagged_field("text_area", :rows => 4, :cols => 60)
  
  def fields_for(name, *args, &block)
    raise ArgumentError, "Missing block" unless block_given?
    options = args.last.is_a?(Hash) ? args.pop : {}
    object = args.first
    builder = options[:builder] || self.class

    yield builder.new(name, object, @template, options, block)
  end
  
  def result_buttons(values = %w{Submit Cancel})
    if values.is_a? String
      values = [values]
    end
    "<p class = \"submit\">" +
    values.inject("") do |text, val|
      text += '<span><input name="result" type="submit" ' +
              "value=\"#{val}\" /></span>"
    end +
    "</p>"
  end
  
  private
  def indicate_required(options)
    options.delete(:required) ? '<span class="required">*</span>' : ""
  end
  
  def error_message_on(object, column)
    begin
      @template.error_message_on(object, column)
    rescue NameError
    end
  end
end
