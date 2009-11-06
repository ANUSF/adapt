class StudyAcknowledgementsController < ApplicationController
  def edit
    @study = Study.find(params[:id])
  end
  
  def update
    @study = Study.find(params[:id])

    #TODO hack!
    old = ActiveSupport::JSON.decode @study.additional_metadata || "{}"
    @study.attributes = params[:study]
    new = ActiveSupport::JSON.decode @study.additional_metadata
    update_needed = old != new

    if not update_needed or @study.save
      flash[:notice] = "Edits for page 3 were saved." if update_needed
      if params[:result] == "Back"
        redirect_to edit_study_datum_url(@study)
      elsif params[:result] == "Refresh"
        redirect_to edit_study_acknowledgement_url(@study)
      else
        redirect_to @study
      end
    else
      render :action => 'edit'
    end
  end
end
