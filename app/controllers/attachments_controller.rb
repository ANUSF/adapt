class AttachmentsController < ApplicationController
  # ----------------------------------------------------------------------------
  # Authorization and other filtering.
  # ----------------------------------------------------------------------------

  # -- find referenced resources before performing authorization
  before_authorization_filter :find_study,      :only   => [ :new, :create ]
  before_authorization_filter :find_attachment, :except => [ :new, :create ]

  # -- declare access permissions via the 'verboten' plugin
  permit :show, :download,                        :if => :may_view
  permit :new, :create, :edit, :update, :destroy, :if => :may_edit

  private

  # Finds the study with the id in the 'study_id' request parameter.
  def find_study
    @study = Study.find_by_id(params[:study_id])
  end

  # Finds the attachment with id specified in the request and the study it
  # belongs to.
  def find_attachment
    @attachment = Attachment.find_by_id(params[:id])
    @study = @attachment.study if @attachment
  end

  # Whether the current user may view the referenced study.
  def may_view
    @study and @study.can_be_viewed_by current_user
  end

  # Whether the current user may edit the referenced study.
  def may_edit
    @study and @study.can_be_edited_by current_user
  end

  # ----------------------------------------------------------------------------
  # The standard actions this controller implements. All action code relies on
  # the @study and @attachment variables having been set by before filters.
  # ----------------------------------------------------------------------------
  public

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

  # ----------------------------------------------------------------------------
  # Additional actions this controller provides.
  # ----------------------------------------------------------------------------

  # This custom action provides a file download for the referenced attachment.
  def download
    send_data(@attachment.data, :filename => @attachment.name)
  end
end
