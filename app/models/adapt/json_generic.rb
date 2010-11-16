class Adapt::JsonGeneric
  attr_accessor :value

  def initialize(value); @value = value end

  def persisted?; false end
end
