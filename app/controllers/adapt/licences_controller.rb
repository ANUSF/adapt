class Adapt::LicencesController < Adapt::ApplicationController
  # ----------------------------------------------------------------------------
  # Authorization and other filtering.
  # ----------------------------------------------------------------------------

  # -- find referenced study before performing authorization
  before_authorization_filter :find_licence

  # -- declare access permissions via the 'verboten' plugin
  #    (new and create are currently disabled and may be found obsolete)
  permit :show do @study and @study.can_be_viewed_by current_user end

  private

  # Finds the licence specified in the request and the study it belongs to.
  def find_licence
    @licence = Adapt::Licence.find_by_id(params[:id])
    @study = @licence.study if @licence
  end

  # ----------------------------------------------------------------------------
  # The standard actions this controller implements. All action code relies on
  # the @study variable having been set by a before filter.
  # ----------------------------------------------------------------------------
  public

  def show
    @text = @licence.text(false)
  end
end
