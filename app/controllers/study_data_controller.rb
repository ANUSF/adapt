class StudyDataController < ApplicationController
  permit :edit, :update, :if => :current_user_owns_study

  before_filter :find_study

  def edit
  end
  
  def update
    #TODO hack!
    old = ActiveSupport::JSON.decode @study.additional_metadata || "{}"
    @study.attributes = params[:study]
    new = ActiveSupport::JSON.decode @study.additional_metadata
    update_needed = old != new

    if not update_needed or @study.save
      flash[:notice] = "Edits for page 2 were saved." if update_needed
      if params[:result] == "Back"
        redirect_to edit_study_url(@study)
      else
        redirect_to edit_study_acknowledgement_url(@study)
      end
    else
      render :action => 'edit'
    end
  end

  private

  def find_study
    return @study if defined? @study
    @study = logged_in && current_user.studies.find_by_id(params[:id])
  end

  def current_user_owns_study
    not find_study.nil?
  end
end
