class Adapt::Doi < ActiveRecord::Base
  set_table_name 'adapt_dois'

  validates_presence_of :title, :message => 'May not be blank.'
  validates_presence_of :creators, :message => 'At least one name must be given.'
  validates_presence_of :publisher, :message => 'May not be blank.'
  validates_presence_of :year

  def data_cite
    av = ActionView::Base.new(*Rails.configuration.paths["app/views"])
    av.assign :doi => self
    av.render 'adapt/dois/datacite.xml'
  end
end
