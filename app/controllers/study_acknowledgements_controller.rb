class StudyAcknowledgementsController < ApplicationController
  def edit
    @study = Study.find(params[:id])
  end
  
  def update
    @study = Study.find(params[:id])

    current = @study.attributes
    @study.attributes = params[:study]
    update_needed = @study.attributes != current

    if not update_needed or @study.save
      flash[:notice] = "Edits for page 3 were saved." if update_needed
      if params[:result] == "Back"
        redirect_to edit_study_datum_url(@study)
      else
        redirect_to @study
      end
    else
      render :action => 'edit'
    end
  end
end
