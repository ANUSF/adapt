class Adapt::Generic
  def initialize(data)
    data = { :value => data } if data.is_a? String
    class << self; self; end.class_eval { attr_accessor *data.keys }
    data.each { |key, val| instance_variable_set(:"@#{key}", val) }
  end

  def persisted?
    false
  end
end
