class StudiesControllerBase < ApplicationController
  before_authorization_filter :find_study

  permit :edit, :update, :if => :may_edit

  protected

  def find_study
    @study = Study.find_by_id(params[:id])
  end

  def may_view
    @study and @study.can_be_viewed_by current_user
  end

  def may_edit
    @study and @study.can_be_edited_by current_user
  end

  def may_submit
    @study and @study.can_be_submitted_by current_user
  end

  def update_attributes
    #TODO hack!
    old = ActiveSupport::JSON.decode @study.additional_metadata || "{}"
    @study.attributes = params[:study]
    new = ActiveSupport::JSON.decode @study.additional_metadata
    @changed = old != new
  end
end
