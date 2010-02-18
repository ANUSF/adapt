class Licence < ActiveRecord::Base
  belongs_to :study

  attr_accessible :signed_by, :email, :access_mode, :signed_date

  validates_presence_of :signed_by
  validates_presence_of :email
  validates_presence_of :access_mode, :message => "Please select one."
  validates_presence_of :signed_date

  def selections(column)
    case column.to_sym
    when :access_mode
      [ [ "Unrestricted (see 3.i)", "A"],
        [ "By permission (see 3.ii)", "B" ],
        [ "To be negotiated", "C" ] ]
    end
  end

  def empty_selection(column)
    column.to_sym == :access_mode ? "-- Please select --" : false
  end
end
