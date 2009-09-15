require 'test_helper'

class StudyDataControllerTest < ActionController::TestCase
  def test_edit
    get :edit, :id => StudyData.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    StudyData.any_instance.stubs(:valid?).returns(false)
    put :update, :id => StudyData.first
    assert_template 'edit'
  end
  
  def test_update_valid
    StudyData.any_instance.stubs(:valid?).returns(true)
    put :update, :id => StudyData.first
    assert_redirected_to root_url
  end
end
