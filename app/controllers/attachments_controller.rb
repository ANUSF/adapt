class AttachmentsController < ApplicationController
  def index
    @attachments = Attachment.all
  end
  
  def new
    @attachment = Attachment.new
  end
  
  def create
    @attachment = Attachment.new(params[:attachment])
    if @attachment.save
      flash[:notice] = "Successfully created attachment."
      redirect_to attachments_url
    else
      render :action => 'new'
    end
  end
  
  def edit
    @attachment = Attachment.find(params[:id])
  end
  
  def update
    @attachment = Attachment.find(params[:id])
    if @attachment.update_attributes(params[:attachment])
      flash[:notice] = "Successfully updated attachment."
      redirect_to attachments_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @attachment = Attachment.find(params[:id])
    @attachment.destroy
    flash[:notice] = "Successfully deleted attachment '#{@attachment.name}'"
    redirect_to attachments_url
  end
end
