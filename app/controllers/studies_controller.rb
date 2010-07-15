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
  permit :approve,              :if => :may_approve
  permit :store,                :if => :may_store

  before_filter :prepare_for_edit, :only => [ :edit, :update, :submit ]
  before_filter :ensure_licence,   :only => [ :edit, :submit ]

  private

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

  # Whether the current user may destroy the referenced study.
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

  # Whether the current user may store the referenced study.
  def may_store
    @study and @study.can_be_stored_by current_user
  end

  def prepare_for_edit
    @button_texts = [ 'Apply Changes', 'Discard Changes', 'Save and Exit' ]
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
      goto :index, :notice => 'Study creation cancelled.'
    else
      @study = current_user.studies.new(params[:study])

      if @study.save
        flash[:notice] = 'Study entry created.'
        redirect_to edit_study_url(@study)
      else
        flash.now[:error] =
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
    result = params[:result] || ''
    if result.starts_with? 'Discard'
      goto :edit, :notice => 'Reverted to previously saved state.'
    elsif params[:commit] == 'Submit this study' and may_submit
      submit
    elsif @study.update_attributes(params[:study])
      next_action = result.ends_with?("Exit") ? :show : :edit
      goto next_action, :notice => 'Changes were saved succesfully.'
    else
      goto :edit, :error => 'Changes could not be saved.'
    end
  end
  
  def destroy
    @study.destroy
    goto :index, :notice => 'Successfully destroyed study.'
  end

  # ----------------------------------------------------------------------------
  # Additional actions this controller provides.
  # ----------------------------------------------------------------------------

  def submit
    if @study.status == 'incomplete'
      goto :edit, :error => 'This study is not yet ready for submission.'
    elsif @study.status != 'unsubmitted'
      goto :show, :error => 'This study has already been submitted.'
    else
      if params[:study] and not @study.update_attributes(params[:study])
        goto :edit, :error => 'Changes could not be saved.'
      elsif licence_okay
        begin
          @study.submit(params[:licence_text] || '')
        rescue Exception => ex
          log_and_notify_of_error ex
          goto :edit, :error => 'An error occurred. Please try again later.'
        else
          goto :show, :notice => 'Study submitted and pending approval.'
        end
      elsif not params[:result].blank?
        goto :edit, :notice => 'Study submission has been cancelled.'
      else
        flash[:notice] = "Access to the data will be " +
          @study.licence.access_phrase + ". Please review and confirm."
        redirect_to @study.licence
      end
    end
  end

  def approve
    if params[:result] == 'Reopen'
      reopen
    else
      begin
        @study.approve User.archivists.find(params[:study][:archivist])
      rescue Exception => ex
        log_and_notify_of_error ex
        show_error ex
      else
        flash.now[:notice] = "Study approval successful!"
      end
    end
    render :action => :show
  end

  def store
    if params[:result] == 'Reopen'
      reopen
    else
      begin
        @study.store params[:study][:id_range][0,1]
      rescue Exception => ex
        log_and_notify_of_error ex
        show_error ex
      else
        flash.now[:notice] = "Study stored successfully!"
      end
    end
    render :action => :show
  end

  private

  def reopen
    @study.reopen
    flash.now[:notice] = 'Study reopened for editing be depositor.'
  end

  def show_error(ex)
    flash.now[:error] = """
The following error occurred: #{ex.to_s}.
Please try again in a little while.
If you still get an error, please notify the developer.
"""
  end

  def log_and_notify_of_error(ex)
    Rails.logger.error(ex)
    unless Rails.env == 'development'
      UserMailer.deliver_error_notification(exception)
    end
  end

  def goto(action, flash_options)
    flash_options.each { |key, val| flash[key] = val }
    redirect_to :action => action
  end

  def licence_okay
    if params[:licence_text].blank?
      @study.owner.is_archivist and @study.skip_licence
    else
      params[:result] == 'Accept'
    end
  end
end
