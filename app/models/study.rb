class Study < ActiveRecord::Base
  belongs_to :user

  attr_accessible :name, :title
end
