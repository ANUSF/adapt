class StudyDataController < ApplicationController
  def edit
    @study = Study.find(params[:id])
  end
  
  def update
    @study = Study.find(params[:id])
    if @study.update_attributes(params[:study])
      flash[:notice] = "Successfully updated study data."
      redirect_to root_url
    else
      render :action => 'edit'
    end
  end
end
