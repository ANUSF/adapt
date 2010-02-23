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
    if @study.status != "unsubmitted"
      redirect_to submit_study_url(@study)
    else
      @licence = @study.build_licence(:signed_by => current_user.name,
                                      :email => current_user.email,
                                      :signed_date => Date.today.inspect)
    end
  end

  def create
    if @study.status != "unsubmitted"
      redirect_to submit_study_url(@study)
    elsif params[:result] == "Cancel"
      flash[:notice] = "Study not submitted."
      redirect_to @study
    else
      @licence = @study.build_licence(params[:licence])
      if @licence.save
        flash[:notice] = "Access to the data will be " +
          @licence.access_phrase + ". Please review and confirm."
        redirect_to @licence
      else
        flash.now[:error] =
          "Something went wrong. Please correct the fields marked in red."
        render :action => :new
      end
    end
  end

  def show
  end

  # ----------------------------------------------------------------------------
  # Additional actions this controller provides.
  # ----------------------------------------------------------------------------

  def accept
    if @study.status == "unsubmitted"
      if params[:result] == "Accept"
        @study.update_attribute(:status, "submitted")
        flash[:notice] = "Study submitted and pending approval."
      else
        @licence.destroy
        flash[:notice] = "Licence not accepted."
      end
    end
    redirect_to @study
  end
end
