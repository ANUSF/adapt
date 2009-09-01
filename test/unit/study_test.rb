require 'test_helper'

class StudyTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Study.new.valid?
  end
end
