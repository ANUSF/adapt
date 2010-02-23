class Licence < ActiveRecord::Base
  belongs_to :study

  attr_accessible :signed_by, :email, :access_mode, :signed_date

  validates_presence_of :signed_by, :message => "Name required."
  validates_presence_of :email, :message => "Contact email required."
  validates_presence_of :access_mode, :message => "Please select one."
  validates_presence_of :signed_date, :message => "Date required."

  validates_format_of   :signed_by,
    :with => /\A[\w -]*\Z/,
    :message => "Invalid name - only letters, spaces and hyphens are allowed."
  validates_format_of   :signed_by,
    :with => /\A[^\d_]*\Z/,
    :message => "Invalid name - only letters, spaces and hyphens are allowed."
  validates_format_of   :email,
    :with => /\A([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4})?\Z/i,
    :message => "Invalid email address."

  validates_inclusion_of :access_mode, :in => ['', 'A', 'B', 'S'],
                         :message => "Value must be A, B or S."

  validates_each :signed_date do |record, attr, value|
    date = begin Date.parse(value) rescue nil end
    if date
      if value =~ /\b\d\d?\/\d\d?\/\d{2,4}\b/
        record.errors.add attr, "Ambiguous date format."
      elsif not (2010..2999).include? date.year
        record.errors.add attr, "Invalid year: #{date.year}"
      end
    else
      record.errors.add attr, "Unknown date format."
    end
  end

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
end
