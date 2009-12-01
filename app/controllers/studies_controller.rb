class StudiesController < ApplicationController
  before_authorization_filter :find_study

  permit :index, :new, :create, :if => :logged_in
  permit :show, :if => :may_view
  permit :edit, :update, :if => :may_edit
  permit :destroy, :if => :may_edit
  permit :submit, :if => :may_submit

  def index
    @studies =
      case current_user && current_user.role
      when 'contributor' then current_user.studies
      when 'archivist'   then current_user.studies_in_curation
      when 'admin'       then Study.all
      end
  end
  
  def new
    @study = current_user.studies.new
  end
  
  def create
    @study = current_user.studies.new(params[:study])
    @study.status = "incomplete"
    if @study.save
      flash[:notice] = "Study entry created."
      redirect_to edit_study_datum_url(@study)
    else
      render :action => 'new'
    end
  end
  
  def show
  end
  
  def edit
  end
  
  def update
    if params[:result] == "Cancel"
      flash[:notice] = "Edit cancelled."
      redirect_to @study
    else
      @study.attributes = params[:study]

      if @study.save
        flash[:notice] = "Changes were saved succesfully."
        if params[:result] == "Refresh"
          redirect_to edit_study_url(@study)
        else
          redirect_to @study
        end
      else
        render :action => 'edit'
      end
    end
  end
  
  def destroy
    @study.destroy
    flash[:notice] = "Successfully destroyed study."
    redirect_to studies_url
  end

  def submit
    @study.status = "submitted"
    @study.save!
    redirect_to @study
  end

  protected

  def find_study
    @study = Study.find_by_id(params[:id])
  end

  def may_view
    @study and @study.can_be_viewed_by current_user
  end

  def may_edit
    @study and @study.can_be_edited_by current_user
  end

  def may_submit
    @study and @study.can_be_submitted_by current_user
  end
end
