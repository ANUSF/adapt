class Licence < ActiveRecord::Base
  belongs_to :study

  attr_accessible :signed_by, :email, :access_mode, :signed_date

  validates_presence_of :signed_by
  validates_presence_of :email
  validates_presence_of :access_mode
  validates_presence_of :signed_date
end
