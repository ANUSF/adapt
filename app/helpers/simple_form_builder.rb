require 'haml'

class SimpleFormBuilder < ActionView::Helpers::FormBuilder
  def self.create_tagged_field(method_name, default_options = {})
    define_method(method_name) do |column, *args|
      create_field(column, default_options, *args) do |f|
        args = f.args.clone
        args << f.options unless f.options.empty?
        super(column, *args)
      end
    end
  end

  extend ActionView::Helpers::TagHelper
  extend ActionView::Helpers::FormTagHelper

  for name in field_helpers - %w{text_area hidden_field check_box select}
    create_tagged_field(name, :size => 40)
  end
  
  create_tagged_field("date_select", :include_blank => true,
                      :start_year => Time.now.year - 100)
  create_tagged_field("datetime_select", :include_blank => true)
  create_tagged_field("select")
  create_tagged_field("text_area", :rows => 4, :cols => 60)
  
  def check_box(column, *args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    label = options.delete(:label) || try(:label_for, column) || column
    haml { '
%span
  = super(column, *args)
  = label
' }
  end

  def select(column, *args)
    create_field(column, {}, *args) do |f|
      selections = f.args.empty? ? selections_for(column) : f.args[0]
      empty = try :empty_selection, column
      selections = [[empty, ""]] + selections if empty

      multi = f.options.delete(:repeatable) || try(:is_repeatable?, column)
      multi = multi ? "multiple" : nil
      size = f.options.delete(:size) || (6 if multi)

      current = @object.send(column) || []
      name = multi ? "#{f.name}[]" : f.name

      haml { '
%select{ :id => f.ident, :name => name, :multiple => multi, :size => size }
  - for (k, v) in selections
    - selected = current.include?(v) ? "selected" : nil
    %option{ :value => v, :selected => selected }= k
' }
    end
  end

  def structured(column, *args)
    create_field(column, {}, *args) do |f|
      subfields = if f.args.empty? then try(:subfields, column)
                  else f.args end
      subfields = [column] if subfields.empty?
      size = f.options.delete(:size) || 30
      multi = f.options.delete(:repeatable) || try(:is_repeatable?, column)

      current = @object.send(column) || (multi ? [] : {})

      haml { '
.row
  - for sub in subfields
    .form-field
      %label{ :for => f.ident }= sub.humanize
      - if multi
        - for i in 0..current.size
          - ident = "#{f.ident}_#{i}_#{sub}"
          - name  = "#{f.name}[#{i}][#{sub}]"
          - value = (current[i] || {})[sub]
          %br
          %input{ :id => ident, :type => "text", :name => name, |
                  :value => value, :size => size } |
      - else
        - ident = "#{f.ident}_#{sub}"
        - name  = "#{f.name}[#{sub}]"
        - value = current[sub]
        %br
        %input{ :id => ident, :type => "text", :name => name, |
                :value => value, :size => size } |
' }
    end
  end

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
    attr_accessor :name, :ident, :args, :options
    def initialize(name, ident, args, options)
      self.name    = name
      self.ident   = ident
      self.args    = args
      self.options = options
    end
  end

  def try(method_name, *args)
    @object.send method_name, *args if @object.respond_to? method_name
  end

  def create_field(column, default_options, *args)
    raise ArgumentError, "Missing block" unless block_given?

    options = default_options.merge(args.last.is_a?(Hash) ? args.pop : {})
    label = options.delete(:label) || try(:label_for, column) || column
    title = options.delete(:title) || try(:help_on, column)
    required = options.delete(:required)

    ident = "#{@object_name}_#{column}"
    name  = "#{@object_name}[#{column}]"
    msg   = @object.errors.on(column)

    haml { '
%div{ :title => title, :class => "form-field" }
  - if not label.blank? or required
    %label{ :for => ident }
      = label.to_s.humanize
      - if required
        %span.required *
    %br
  %span.input= yield Descriptor.new(name, ident, args, options)
  - unless msg.blank?
    %span.formError= msg
  %span.clear
' }
  end

  def selections_for(column)
    (try(:selections, column) || []).map { |x| [x,x] }
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
