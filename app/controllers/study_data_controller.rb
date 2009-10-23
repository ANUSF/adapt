class StudyDataController < ApplicationController
  def edit
    @study = Study.find(params[:id])
  end
  
  def update
    @study = Study.find(params[:id])

    old = ActiveSupport::JSON.decode @study.additional_metadata
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
end
