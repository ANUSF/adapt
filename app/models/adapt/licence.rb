class Adapt::Licence < ActiveRecord::Base
  include ModelSupport
  include LicenceText

  belongs_to :study

  attr_accessible :signed_by, :email, :access_mode, :signed_date

  validates_presence_of :signed_by, :if => :checking,
  :message => "Name required."
  validates_presence_of :email, :if => :checking,
  :message => "Contact email required."
  validates_presence_of :access_mode, :if => :checking,
  :message => "Please select one."
  validates_presence_of :signed_date, :if => :checking,
  :message => "Date required."

  validates_format_of   :signed_by, :with => /\A[\w -]*\Z/,
  :if => :checking,
  :message => "Only letters, spaces and hyphens are allowed."
  validates_format_of   :signed_by, :with => /\A[^\d_]*\Z/,
  :if => :checking,
  :message => "Only letters, spaces and hyphens are allowed."
  validates_format_of   :email,
  :with => /\A([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4})?\Z/i,
  :if => :checking,
  :message => "Does not look like email address."

  validates_inclusion_of :access_mode, :in => [nil, 'A', 'B', 'S'],
  :if => :checking,
  :message => "Value must be A, B or S."

  validates_each :signed_date, :if => :checking do |record, attr, value|
    date = record.parse_and_validate_date(attr, value, Date.today.year - 1)
    record.errors.add attr, "Incomplete date." if date and date.day.nil?
  end

  attr_reader :checking

  def selections(column)
    case column.to_sym
    when :access_mode
      [ [ "A - Unrestricted (see 3.i)", "A"],
        [ "B - By permission (see 3.ii)", "B" ],
        [ "S - To be negotiated", "S" ] ]
    end
  end

  def empty_selection(column)
    column.to_sym == :access_mode ? "" : false
  end

  def text(html = true)
    text = full_text(access_mode)
    unless html
      text.gsub!(/<\/?[^>]*>/, "")  # strips html tags
      text.gsub!(/&[^;]*;/, "")     # strips html entities
      text.gsub!(/^ +/, "")         # removes leading blanks
      text.gsub!(/\n\n\n*/, "\n\n") # removed multiple empty lines
    end
    text
  end

  def access_phrase
    case access_mode
    when 'A' then "unrestricted"
    when 'B' then "subject to written permission"
    when 'S' then "determined according to a separate agreement"
    end
  end
  
  def ready_for_submission?
    @checking = true
    result = valid?
    @checking = false
    result
  end
end
