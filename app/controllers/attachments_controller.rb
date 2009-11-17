class AttachmentsController < ApplicationController
  permit :new, :create, :if => :owns_study
  permit :show, :download, :edit, :update, :destroy, :if => :owns_attachment

  before_authorization_filter :find_study, :only => [ :new, :create ]
  before_authorization_filter :find_attachment, :except => [ :new, :create ]

  def new
    @attachment = @study.attachments.new
  end
  
  def create
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
  end

  def download
    send_data(@attachment.data, :filename => @attachment.name)
  end

  def edit
  end
  
  def update
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
    @attachment.destroy
    flash[:notice] = "Successfully deleted attachment '#{@attachment.name}'"
    redirect_to @attachment.study
  end

  private

  def find_study
    @study = Study.find_by_id(params[:study_id])
  end

  def owns_study
    @study && @study.user == current_user
  end

  def find_attachment
    @attachment = Attachment.find_by_id(params[:id])
  end

  def owns_attachment
    @attachment && @attachment.study.user == current_user
  end
end
