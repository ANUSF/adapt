class StudiesControllerBase < ApplicationController
  before_authorization_filter :find_study

  permit :edit, :update, :if => :owns_study

  # # -- permit can be called with a block, too
  # permit :edit do |user, params|
  #   user.studies.find_by_id(params[:id])
  # end

  protected

  def find_study
    @study = Study.find_by_id(params[:id])
  end

  def owns_study
    @study && @study.user == current_user
  end
end
