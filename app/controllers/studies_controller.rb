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
    @study.status = "unsubmitted"
    if @study.save
      flash[:notice] = "Successfully created study."
      redirect_to @study
    else
      render :action => 'new'
    end
  end
  
  def edit
    @study = Study.find(params[:id])
  end
  
  def update
    @study = Study.find(params[:id])
    if @study.update_attributes(params[:study])
      flash[:notice] = "Successfully updated study."
      redirect_to @study
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
