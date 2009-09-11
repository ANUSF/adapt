class Study < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :title
  validates_presence_of :abstract

  attr_accessible :name, :title, :abstract

  def help_on(column)
    case column.to_sym
    when :name
      "Here you can assign an optional abbreviated name to refer to this " +
        "study by."
    else
      nil
    end
  end
end
