class Adapt::UserSessionsController < ApplicationController
  permit :update do users_may_change_roles and logged_in end

  def update
    @user = current_user
    if @user and params[:adapt_user][:role]
      @user.role = params[:adapt_user][:role]
      if @user.save
        flash[:notice] = "Successfully changed role."
      else
        flash[:error] = "Error in role change."
      end
      redirect_to params[:last_url] || adapt_studies_url
    end
  end
end
