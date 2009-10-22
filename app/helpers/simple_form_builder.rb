require 'haml'

class SimpleFormBuilder < ActionView::Helpers::FormBuilder
  def multiselect(column, *args)
    create_field(column, {}, *args) do |d|
      selections = if d.args.size > 0 then d.args[0]
                   elsif @object.respond_to? :selections
                     @object.selections(column).map { |x| [x,x] }
                   else [] end
      size = d.options.delete(:size) || 6
      current = @object.send(column) || []
      haml { '
%select{ :id => d.id, :name => "#{d.name}[]", :multiple => "multiple", |
         :size => size } |
  - for (k, v) in selections
    - selected = current.include?(v) ? "selected" : nil
    %option{ :value => v, :selected => selected }= k
' }
    end
  end

  def self.create_tagged_field(method_name, default_options = {})
    define_method(method_name) do |column, *args|
      create_field(column, default_options, *args) do |d|
        args = d.args
        if method_name.to_s == :select and args.size < 1
          args[0] = [ ["-- please select --", ""] ]
          if @object.respond_to? :selections
            args[0] += @object.selections(column).map { |x| [x,x] }
          end
        end
        args << d.options unless d.options.empty?

        super(column, *args)
      end
    end
  end

  extend ActionView::Helpers::TagHelper
  extend ActionView::Helpers::FormTagHelper

  for name in field_helpers - ["text_area", "hidden_field"]
    create_tagged_field(name, :size => 40)
  end
  
  create_tagged_field("date_select", :include_blank => true,
                      :start_year => Time.now.year - 100)
  create_tagged_field("datetime_select", :include_blank => true)
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
  
  private
  class Descriptor
    attr_accessor :name, :id, :args, :options
    def initialize(name, id, args, options)
      self.name = name
      self.id = id
      self.args = args
      self.options = options
    end
  end

  def create_field(column, default_options, *args)
    raise ArgumentError, "Missing block" unless block_given?

    options = default_options.merge(args.last.is_a?(Hash) ? args.pop : {})
    label = options.delete(:label) || 
      if @object.respond_to? :label_for then @object.label_for column end ||
      column
    title = options.delete(:title) ||
      if @object.respond_to? :help_on then @object.help_on column end

    id = "#{@object_name}_#{column}"
    name = "#{@object_name}[#{column}]"
    required = options.delete(:required)
    msg = @object.errors.on(column)

    haml { '
%div{ :title => title, :class => "form-field" }
  - if not label.blank? or required
    %label{ :for => id }
      = label.to_s.humanize
      - if required
        %span.required *
    %br
  %span.input= yield Descriptor.new(name, id, args, options)
  - unless msg.blank?
    %span.formError= msg
  %span.clear
' }
  end

  def error_message_on(object, column)
    begin
      @template.error_message_on(object, column)
    rescue NameError
    end
  end

  def haml(&block)
    raise ArgumentError, "Missing block" unless block_given?
    Haml::Engine.new(block.call).render(block.binding)
  end
end
