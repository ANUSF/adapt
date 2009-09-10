class StudiesController < ApplicationController
  def index
    @studies = Study.all
  end
  
  def show
    @study = Study.find(params[:id])
  end
  
  def new
    @study = Study.new
  end
  
  def create
    @study = current_user.studies.new(params[:study])
    if @study.save
      flash[:notice] = "Successfully created study."
      redirect_to [current_user, @study]
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
      redirect_to [current_user, @study]
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @study = Study.find(params[:id])
    @study.destroy
    flash[:notice] = "Successfully destroyed study."
    redirect_to user_studies_url
  end
end
