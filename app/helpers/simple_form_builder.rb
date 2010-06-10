# The custom form builder we use in this application.
class SimpleFormBuilder < ActionView::Helpers::FormBuilder

  # Overrides the method with the given name with our standard replacement.
  def self.create_tagged_field(method_name, default_options = {})
    define_method(method_name) do |column, *args|
      create_field(column, default_options, *args) do |f|
        args = f.args.clone
        args << f.options unless f.options.empty?
        super(column, *args)
      end
    end
  end

  # -- grab names of some standard tag helpers and override most of them
  extend ActionView::Helpers::TagHelper
  extend ActionView::Helpers::FormTagHelper

  for name in field_helpers - %w{fields_for text_area text_field hidden_field
                                 check_box select file_field}
    create_tagged_field(name, :size => 40)
  end

  # -- more automated overrides, but with different default options
  create_tagged_field("date_select", :include_blank => true,
                      :start_year => Time.now.year - 100)
  create_tagged_field("datetime_select", :include_blank => true)
  create_tagged_field("select")
  create_tagged_field("text_area", :rows => 4, :cols => 60)
  
  def file_field(column, *args)
    create_field(column, {}, *args) do |f|
      klass = f.options.delete(:multi) ? "multi" : ""
      size = f.options.delete(:size) || 40
      args = f.args.clone
      args << f.options unless f.options.empty?
      haml { '
%input{ :class => klass, :id => f.ident, :name => f.name, :type => "file", |
        :size => size }
' }
    end
  end
  
  # The new check_box helper uses a layout different from our generic one.
  def check_box(column, options = {})
    label = options.delete(:label) || try(:label_for, column) ||
      column.to_s.humanize
    selections = try(:selections, column) || []
    unchecked_value = options.delete(:unchecked_value) || selections[0] || "0"
    checked_value = options.delete(:checked_value) || selections[1] || "1"
    haml { '
%span
  = super(column, options, checked_value, unchecked_value)
  = label
' }
  end

  # The new radio_button helper uses a layout different from our generic one.
  def radio_button(column, value, options = {})
    ident = "#{object_ident}_#{column}"
    name  = "#{@object_name}[#{column}]"
    msg   = @object.errors.on(column)
    check = (@object.send(column) == value)
    label = options.delete(:label) || value
    haml { '
%span
  %input{ :id => ident, :name => name, :type => "radio", :value => value, |
          :checked => check } |
  = label
' }
  end

  # A versatile helper method for creating selection boxes.
  def select(column, *args)
    create_field(column, {}, *args) do |f|
      selections = f.args.empty? ? selections_for(column) : f.args[0]
      empty = try :empty_selection, column
      selections = [[empty, ""]] + selections if empty
      other = f.options.delete(:allow_other) || try(:allow_other?, column)

      multi = f.options.delete(:repeatable) || try(:is_repeatable?, column)
      multi = multi ? "multiple" : nil
      size = f.options.delete(:size) || (6 if multi)

      current = try(column) || []
      current = [current] unless multi or current == []
      current_other = (current - selections.transpose[1]).join(", ") if other
      name = multi ? "#{f.name}[]" : f.name

      haml { '
%select{ :id => f.ident, :name => name, :multiple => multi, :size => size }
  - for (k, v) in selections
    - selected = current.include?(v) ? "selected" : nil
    %option{ :value => v, :selected => selected }= k
- if other
  %br
  %span{ :title => "Enter a comma-separated list of additional values here." }
    Other:
    %input{ :id => f.ident, :name => name, :type => "text", :size => 25, |
            :value => current_other } |
' }
    end
  end

  def text_field(column, *args)
    create_field(column, {}, *args) do |f|
      size = f.options.delete(:size) || 40
      multi = f.options.delete(:repeatable) || try(:is_repeatable?, column)
      current = @object.send(column) || (multi ? [] : {})

      haml { '
- if multi
  - for i in 0..current.size
    - ident = "#{f.ident}_#{i}"
    - name  = "#{f.name}[#{i}]"
    - value = current[i]
    %input{ :id => ident, :type => "text", :name => name, |
            :value => value, :size => size } |
- else
  - ident = "#{f.ident}"
  - name  = "#{f.name}"
  - value = current
  %input{ :id => ident, :type => "text", :name => name, |
          :value => value, :size => size } |
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
- if multi
  - for i in 0..current.size
    .row
      - for sub in subfields
        .form-field
          - ident = "#{f.ident}_#{i}_#{sub}"
          - name  = "#{f.name}[#{i}][#{sub}]"
          - value = (current[i] || {})[sub]
          %label{ :for => f.ident }= sub.to_s.humanize
          %br
          %input{ :id => ident, :type => "text", :name => name, |
                  :value => value, :size => size } |
    .clear
- else
  .row
    - for sub in subfields
      .form-field
        - ident = "#{f.ident}_#{sub}"
        - name  = "#{f.name}[#{sub}]"
        - value = current[sub]
        %label{ :for => f.ident }= sub.to_s.humanize
        %br
        %input{ :id => ident, :type => "text", :name => name, |
                :value => value, :size => size } |
' }
    end
  end

  def errors_on(column)
    msg = @object.errors.on(column)
    msg = msg.join(" ") unless msg.nil? or msg.is_a? String
    if msg.blank?
      ''
    else
      haml { '
%label
  &nbsp;
  %em.error= msg
' }
    end
  end

  def result_buttons(values = %w{Save Cancel})
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
    inline = options.delete(:inline)
    label_inline = options.delete(:label_inline)
    label = options.delete(:label) || try(:label_for, column) ||
      column.to_s.humanize
    title = options.delete(:title) || try(:help_on, column) || label
    required = options.delete(:required)

    ident = "#{object_ident}_#{column}"
    name  = "#{@object_name}[#{column}]"
    msg   = @object.errors.on(column)

    content = haml { '
- unless label.blank? and msg.blank? and not required
  %label{ :for => ident }
    - unless label.blank?
      = label.to_s.humanize
    - if required
      %em *
    - unless msg.blank?
      %em.error= msg
  - unless label_inline
    %br
%span.input= yield Descriptor.new(name, ident, args, options)
' }

    haml { '
- if inline
  %span{ :title => title }= content
- else
  %div{ :title => title, :class => "form-field" }
    = content
    %span.clear
' }
  end

  def object_ident
    @object_ident ||= @object_name.gsub(/\[/, '_').gsub(/\]/, '')
  end

  def selections_for(column)
    (try(:selections, column) || []).map do |x|
      if x.is_a?(Array) then x else [x.to_s.humanize, x] end
    end
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
