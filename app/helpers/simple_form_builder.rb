require 'haml'

class SimpleFormBuilder < ActionView::Helpers::FormBuilder
  def self.create_tagged_field(name, default_options = {})
    define_method(name) do |column, *args|
      options = default_options.merge(args.last.is_a?(Hash) ? args.pop : {})
      label = options.delete(:label) || 
        if @object.respond_to? :label_for then @object.label_for column end ||
        column
      title = options.delete(:title) ||
        if @object.respond_to? :help_on then @object.help_on column end

      if name.to_str == "select" and @object.respond_to? :selections
        args[0] = [ ["-- please select --", ""] ] +
          @object.selections(column).map { |x| [x,x] }
      end
      args << options unless options.empty?
      
      content =
        @template.content_tag("label",
                              label.to_s.humanize + indicate_required(options),
                              :for => "#{@object_name}_#{column}") +
        @template.content_tag("br") +
        @template.content_tag("span", super(column, *args), :class => "input")
     
      msg = @object.errors.on(column)
      unless msg.blank?
        content += @template.content_tag("span", msg, :class => "formError")
      end
      @template.content_tag("p", content, :title => title) +
        @template.content_tag("div", nil, :class => "clear")
    end
  end

  extend ActionView::Helpers::TagHelper
  extend ActionView::Helpers::FormTagHelper

  for name in field_helpers - ["text_area", "hidden_field"]
    create_tagged_field(name, :size => 40)
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
    values = [values] if values.is_a? String
    haml { '
%p.submit
  - for val in values
    %span
      %input{ :name => "result", :type => "submit", :value => "#{val}" }
'   }
  end
  
  def multiselect(column, *args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    label = options.delete(:label) || 
      if @object.respond_to? :label_for then @object.label_for column end ||
      column
    title = options.delete(:title) ||
      if @object.respond_to? :help_on then @object.help_on column end
    size = options.delete(:size) || 6

    if @object.respond_to? :selections
      args[0] = @object.selections(column).map { |x| [x,x] }
    end
    args << options unless options.empty?

    msg = @object.errors.on(column)
    id = "#{@object_name}_#{column}"
    name = "#{@object_name}[#{column}][]"
    current = @object.send(column)
    
    haml { '
%p{ :title => title }
  %label{ :for => id }
    = label.to_s.humanize + indicate_required(options)
  %br
  %span.input
    %select{ :id => id, :name => name, :multiple => "multiple", :size => size }
      - for (k, v) in args[0]
        - if current.include? v
          %option{ :value => v, :selected => "selected" }= k
        - else
          %option{ :value => v }= k
  - unless msg.blank?
    %span.formError= msg
.clear
' }
  end

  private
  def indicate_required(options)
    options.delete(:required) ? haml { '%span.required *' } : ""
  end
  
  def error_message_on(object, column)
    begin
      @template.error_message_on(object, column)
    rescue NameError
    end
  end

  def haml(&block)
    Haml::Engine.new(block.call).render(block.binding)
  end
end
