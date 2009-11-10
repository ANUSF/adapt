class AttachmentsController < ApplicationController
  def new
    @study = Study.find(params[:study_id])
    @attachment = @study.attachments.new
  end
  
  def create
    @study = Study.find(params[:study_id])

    if params[:result] == "Cancel"
      flash[:notice] = "Attachment upload cancelled."
      redirect_to @study
    else
      @attachment = @study.attachments.new(params[:attachment])
      if @attachment.save
        flash[:notice] = "Attachment successfully uploaded."
        redirect_to @attachment
      else
        render 'new'
      end
    end
  end
  
  def show
    @attachment = Attachment.find(params[:id])
  end

  def download
    @attachment = Attachment.find(params[:id])
    send_data(@attachment.data, :filename => @attachment.name)
  end

  def edit
    @attachment = Attachment.find(params[:id])
  end
  
  def update
    @attachment = Attachment.find(params[:id])
    if params[:result] == "Cancel"
      flash[:notice] = "Attachment update cancelled."
      redirect_to @attachment
    else
      if @attachment.update_attributes(params[:attachment])
        flash[:notice] = "Attachment information successfully updated."
        redirect_to @attachment
      else
        render 'edit'
      end
    end
  end

  def destroy
    @attachment = Attachment.find(params[:id])
    @attachment.destroy
    flash[:notice] = "Successfully deleted attachment '#{@attachment.name}'"
    redirect_to @attachment.study
  end
end
