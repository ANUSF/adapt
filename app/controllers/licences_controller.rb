class LicencesController < ApplicationController
  # ----------------------------------------------------------------------------
  # Authorization and other filtering.
  # ----------------------------------------------------------------------------

  # -- find referenced study before performing authorization
  before_authorization_filter :find_licence

  # -- declare access permissions via the 'verboten' plugin
  #    (new and create are currently disabled and may be found obsolete)
  permit :show,   :if => :may_view
  permit :accept, :if => :may_create

  private

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

  def show
    @text = @licence.text(false)
  end

  # ----------------------------------------------------------------------------
  # Additional actions this controller provides.
  # ----------------------------------------------------------------------------

  def accept
    if @study.status == "unsubmitted"
      if params[:result] == "Accept"
        if @study.submit(params[:licence_text])
          flash[:notice] = "Study submitted and pending approval."
        else
          flash[:error] = "Study submission failed for unknown reasons."
        end
      else
        flash[:notice] = "The study has not yet been submitted."
      end
    end
    redirect_to @study
  end
end
