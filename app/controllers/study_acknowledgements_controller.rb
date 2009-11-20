class StudyAcknowledgementsController < StudiesControllerBase
  def edit
  end
  
  def update
    update_attributes

    if not @changed or @study.save
      flash[:notice] = "Edits for page 3 were saved." if @changed
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
