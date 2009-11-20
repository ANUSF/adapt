class StudiesControllerBase < ApplicationController
  before_authorization_filter :find_study

  permit :edit, :update, :if => :owns_study

  protected

  def find_study
    @study = Study.find_by_id(params[:id])
  end

  def owns_study
    logged_in && @study && @study.user == current_user
  end

  def update_attributes
    #TODO hack!
    old = ActiveSupport::JSON.decode @study.additional_metadata || "{}"
    @study.attributes = params[:study]
    new = ActiveSupport::JSON.decode @study.additional_metadata
    @changed = old != new
  end
end
