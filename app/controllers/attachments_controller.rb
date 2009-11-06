class AttachmentsController < ApplicationController
  before_filter :get_study

  def new
    @attachment = @study.attachments.new
  end
  
  def show
    @attachment = @study.attachments.find(params[:id])
  end

  def download
    @attachment = @study.attachments.find(params[:id])
    send_data(@attachment.data, :filename => @attachment.name)
  end

  def create
    if params[:result] == "Cancel"
      flash[:notice] = "Attachment upload cancelled."
      redirect_to @study
    else
      @attachment = @study.attachments.new(params[:attachment])
      if @attachment.save
        flash[:notice] = "Attachment successfully uploaded."
        redirect_to [@study, @attachment]
      else
        render :action => 'new'
      end
    end
  end
  
  def edit
    @attachment = @study.attachments.find(params[:id])
  end
  
  def update
    @attachment = @study.attachments.find(params[:id])
    if params[:result] == "Cancel"
      flash[:notice] = "Attachment update cancelled."
      redirect_to [@study, @attachment]
    else
      if @attachment.update_attributes(params[:attachment])
        flash[:notice] = "Attachment information successfully updated."
        redirect_to [@study, @attachment]
      else
        render :action => 'edit'
      end
    end
  end

  def destroy
    @attachment = @study.attachments.find(params[:id])
    @attachment.destroy
    flash[:notice] = "Successfully deleted attachment '#{@attachment.name}'"
    redirect_to @study
  end

  private
  def get_study
    @study = Study.find(params[:study_id])
  end
end
