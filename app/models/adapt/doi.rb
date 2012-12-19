class Adapt::Doi < ActiveRecord::Base
  set_table_name 'adapt_dois'

  validates_presence_of :title, :message => 'May not be blank.'
  validates_presence_of :creators, :message => 'At least one name must be given.'
  validates_presence_of :publisher, :message => 'May not be blank.'
  validates_presence_of :year

  def ddi=(uploaded)
  end
end
