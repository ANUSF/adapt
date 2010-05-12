class StudiesController < ApplicationController
  # ----------------------------------------------------------------------------
  # Authorization and other filtering.
  # ----------------------------------------------------------------------------

  # -- find referenced study before performing authorization
  before_authorization_filter :find_study, :except => [ :index, :new, :create ]

  # -- declare access permissions via the 'verboten' plugin
  permit :index, :new, :create, :if => :logged_in
  permit :show,                 :if => :may_view
  permit :edit, :update,        :if => :may_edit
  permit :destroy,              :if => :may_destroy
  permit :submit,               :if => :may_submit
  permit :approve, :reopen,     :if => :may_approve

  before_filter :prepare_for_edit, :only => [ :edit, :update, :submit ]
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
    allowed = @study and @study.can_be_edited_by current_user
    if allowed and @study.is_submitted and current_user.is_archivist
      "ADAPT does not yet offer any pre-publishing functionality. " +
      "Please use Nesstar Publisher for now."
    else
      allowed
    end
  end

  # Whether the current user may edit the referenced study.
  def may_destroy
    @study and @study.can_be_destroyed_by current_user
  end

  # Whether the current user may submit the referenced study.
  def may_submit
    @study and @study.can_be_submitted_by current_user
  end

  # Whether the current user may approve the referenced study.
  def may_approve
    @study and @study.can_be_approved_by current_user
  end

  def prepare_for_edit
    @button_texts = [ 'Apply Changes', 'Undo Changes', 'Save and Exit' ]
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
    @studies = Study.all.select { |s| s.is_listed_for current_user }
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
    @can_submit = (@study.can_be_submitted_by(current_user) and
                   @study.status == "unsubmitted")
  end
  
  def update
    result = params[:result]
    if result.starts_with? "Undo"
      flash[:notice] = "Reverted to previously saved state."
      redirect_to edit_study_url
    else
      success = @study.update_attributes(params[:study])
      if success
        flash[:notice] = "Changes were saved succesfully."
        if result.ends_with? "Exit"
          redirect_to @study
        else
          redirect_to edit_study_url
        end
      else
        flash.now[:error] = "Changes could not be saved:\n\n" +
          @study.errors.map { |attr, txt|
            "#{attr.humanize} - #{txt.downcase}"
          }.join("\n")
        render :action => :edit
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
        (@study.errors.map + @study.licence.errors.map).map { |attr, txt|
        "#{attr.humanize} - #{txt.downcase}"
      }.join("\n")
      render :action => :edit
    elsif @study.status != "unsubmitted"
      flash[:error] = "This study has already been submitted."
      redirect_to @study
    elsif @study.owner.is_archivist and @study.skip_licence
      if @study.submit('')
        flash[:notice] = "Study submitted and pending approval."
      else
        flash[:error] = "Study submission failed for unknown reasons."
      end
      redirect_to @study
    else
      flash[:notice] = "Access to the data will be " +
        @study.licence.access_phrase + ". Please review and confirm."
      redirect_to @study.licence
    end
  end

  def approve
    archivist = User.archivists.find(params[:study][:archivist])
    range_prefix = params[:study][:id_range][0,1]
    @study.approve archivist, range_prefix
    redirect_to studies_url
  end

  def reopen
    @study.reopen
    redirect_to studies_url
  end
end
