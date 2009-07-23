class SubmissionsController < ApplicationController
  def index
    @submissions = Submission.all
  end
  
  def show
    @submission = Submission.find(params[:id])
  end
  
  def new
    @submission = Submission.new
  end
  
  def create
    @submission = Submission.new(params[:submission])
    if @submission.save
      flash[:notice] = "Successfully created submission."
      redirect_to @submission
    else
      render :action => 'new'
    end
  end
  
  def edit
    @submission = Submission.find(params[:id])
  end
  
  def update
    @submission = Submission.find(params[:id])
    if @submission.update_attributes(params[:submission])
      flash[:notice] = "Successfully updated submission."
      redirect_to @submission
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @submission = Submission.find(params[:id])
    @submission.destroy
    flash[:notice] = "Successfully destroyed submission."
    redirect_to submissions_url
  end
end
