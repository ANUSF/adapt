class StudiesController < ApplicationController

  def index
    @studies = current_user.studies.all
  end
  
  def show
    @study = current_user.studies.find(params[:id])
  end
  
  def new
    @study = current_user.studies.new
  end
  
  def create
    @study = current_user.studies.new(params[:study])
    @study.status = "incomplete"
    if @study.save
      flash[:notice] = "Study entry created. Further input required."
      redirect_to edit_study_datum_url(@study)
    else
      render :action => 'new'
    end
  end
  
  def edit
    @study = Study.find(params[:id])
  end
  
  def update
    @study = Study.find(params[:id])

    current = @study.attributes
    @study.attributes = params[:study]
    update_needed = @study.attributes != current

    if not update_needed or @study.save
      flash[:notice] = "Edits for page 1 were saved." if update_needed
      redirect_to edit_study_datum_url(@study)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @study = Study.find(params[:id])
    @study.destroy
    flash[:notice] = "Successfully destroyed study."
    redirect_to studies_url
  end
end
