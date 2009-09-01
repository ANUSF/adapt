require 'test_helper'

class StudiesControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => Study.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Study.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Study.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to study_url(assigns(:study))
  end
  
  def test_edit
    get :edit, :id => Study.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    Study.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Study.first
    assert_template 'edit'
  end
  
  def test_update_valid
    Study.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Study.first
    assert_redirected_to study_url(assigns(:study))
  end
  
  def test_destroy
    study = Study.first
    delete :destroy, :id => study
    assert_redirected_to studies_url
    assert !Study.exists?(study.id)
  end
end
