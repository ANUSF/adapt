require 'test_helper'

class StudyAcknowledgementsControllerTest < ActionController::TestCase
  def test_edit
    get :edit, :id => Study.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    StudyAcknowledgement.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Study.first
    assert_template 'edit'
  end
  
  def test_update_valid
    StudyAcknowledgement.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Study.first
    assert_redirected_to root_url
  end
end
