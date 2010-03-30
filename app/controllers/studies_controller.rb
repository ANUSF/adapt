class StudiesController < ApplicationController
  # ----------------------------------------------------------------------------
  # Authorization and other filtering.
  # ----------------------------------------------------------------------------

  # -- find referenced study before performing authorization
  before_authorization_filter :find_study, :except => [ :index, :new, :create ]

  # -- declare access permissions via the 'verboten' plugin
  permit :index, :new, :create,    :if => :logged_in
  permit :show,                    :if => :may_view
  permit :edit, :update, :destroy, :if => :may_edit
  permit :submit,                  :if => :may_submit
  permit :approve,                 :if => :may_approve

  before_filter :set_view_options, :only => [ :edit, :update ]
  before_filter :ensure_licence,   :only => [ :edit, :submit ]

  protected

  # Finds the study with the id specified in the request.
  def find_study
    @study = Study.find_by_id(params[:id])
  end

  # Whether the current user may view the referenced study.
  def may_view
    @study and @study.can_be_viewed_by current_user
  end

  # Whether the current user may edit the referenced study.
  def may_edit
    @study and @study.can_be_edited_by current_user
  end

  # Whether the current user may submit the referenced study.
  def may_submit
    @study and @study.can_be_submitted_by current_user
  end

  # Whether the current user may approve the referenced study.
  def may_approve
    @study and @study.can_be_approved_by current_user
  end

  def set_view_options
    session['active-tab'] = params['active-tab'] if params['active-tab']
    @active_tab = session['active-tab'] || "#title-fields"
  end

  def ensure_licence
    @study.licence ||= Licence.new(:signed_by => current_user.name,
                                   :email => current_user.email,
                                   :signed_date => current_date)
  end

  # ----------------------------------------------------------------------------
  # The standard actions this controller implements. All action code relies on
  # the @study variable having been set by a before filter.
  # ----------------------------------------------------------------------------
  public

  def index
    @studies =
      case current_user && current_user.role
      when 'contributor'
        current_user.studies
      when 'archivist'
        current_user.studies_in_curation
      when 'admin'
        Study.find :all, :conditions => 'status != "incomplete"'
      end
  end
  
  def new
    @study = current_user.studies.new
  end
  
  def create
    if params[:result] == "Cancel"
      flash[:notice] = "Study creation cancelled."
      redirect_to studies_url
    else
      @study = current_user.studies.new(params[:study])

      if @study.save
        flash[:notice] = "Study entry created."
        redirect_to edit_study_url(@study)
      else
        flash[:error] =
          "Study creation failed. Please correct the fields marked in red."
        render :action => :new
      end
    end
  end
  
  def show
    respond_to do |format|
      format.html
      format.xml
    end
  end
  
  def edit
  end
  
  def update
    result = params[:result]
    if result == "Cancel"
      flash[:notice] = "Edit cancelled."
      redirect_to @study
    else
      okay = @study.update_attributes(params[:study]) and
        @study.licence.update_attributes(params[:licence])
      flash[:notice] = "Changes were saved succesfully." if okay

      if okay and result != "Refresh"
        redirect_to @study
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

  # ----------------------------------------------------------------------------
  # Additional actions this controller provides.
  # ----------------------------------------------------------------------------

  def submit
    if @study.status == "incomplete"
      flash.now[:error] =
        "This study is not yet ready for submission:\n\n" +
        @study.errors.full_messages.join("\n")
      render :action => :edit
    elsif @study.status != "unsubmitted"
      flash[:error] = "This study has already been submitted."
      redirect_to @study
    else
      flash[:notice] = "Access to the data will be " +
        @study.licence.access_phrase + ". Please review and confirm."
      redirect_to @study.licence
    end
  end

  def approve
    @study.status = "approved"
    @study.archivist = User.archivists.find(params[:study][:archivist])
    @study.save!
    redirect_to studies_url
  end
end
