class LicencesController < ApplicationController
  # ----------------------------------------------------------------------------
  # Authorization and other filtering.
  # ----------------------------------------------------------------------------

  # -- find referenced study before performing authorization
  before_authorization_filter :find_study,   :only =>   [ :new, :create ]
  before_authorization_filter :find_licence, :except => [ :new, :create ]

  # -- declare access permissions via the 'verboten' plugin
  permit :new, :create, :if => :may_create
  permit :show,         :if => :may_view

  private

  # Finds the study with the id in the 'study_id' request parameter.
  def find_study
    @study = Study.find_by_id(params[:study_id])
  end

  # Finds the licence specified in the request and the study it belongs to.
  def find_licence
    @licence = Licence.find_by_id(params[:id])
    @study = @licence.study if @licence
  end

  # Whether the current user may view the referenced study.
  def may_view
    @study and @study.can_be_viewed_by current_user
  end

  # Whether the current user may create a licence for the referenced study.
  def may_create
    @study and @study.can_be_submitted_by current_user
  end

  # ----------------------------------------------------------------------------
  # The standard actions this controller implements. All action code relies on
  # the @study variable having been set by a before filter.
  # ----------------------------------------------------------------------------
  public

  def new
    if @study.status == "incomplete"
      flash[:error] = "Please supply all required information."
      redirect_to @study
    elsif @study.status != "unsubmitted"
      flash[:error] = "This study has already been submitted."
      redirect_to @study
    else
      @licence = @study.build_licence(:signed_by => current_user.name,
                                      :email => current_user.email,
                                      :signed_date => Date.today.inspect)
    end
  end

  def create
    if params[:result] == "Accept"
      @licence = @study.build_licence(params[:licence])
      if @licence.save
        @study.update_attribute(:status, "submitted")
        flash[:notice] = "Study successfully submitted and pending approval."
        redirect_to @study
      else
        flash.now[:error] = "There were some errors."
        render :action => :new
      end
    else
      flash[:notice] = "Study not submitted."
      redirect_to @study
    end
  end

  def show
  end

  # ----------------------------------------------------------------------------
  # Additional actions this controller provides.
  # ----------------------------------------------------------------------------

  def accept
  end
end
