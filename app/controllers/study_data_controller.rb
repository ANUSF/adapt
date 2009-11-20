class StudyDataController < StudiesControllerBase
  def edit
  end
  
  def update
    update_attributes

    if not @changed or @study.save
      flash[:notice] = "Edits for page 2 were saved." if @changed
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
