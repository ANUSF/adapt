# The controller for editing and displaying user profiles.
class UsersController < ApplicationController
  # -- declare access permissions via the 'verboten' plugin
  permit :edit, :update, :if => :logged_in

  # ----------------------------------------------------------------------------
  # The actions this controller implements.
  # ----------------------------------------------------------------------------
  def edit
    @user = current_user
  end
  
  def update
    @user = current_user
    @user.attributes = params[:user]
    if params[:user][:role] and users_may_change_roles
      @user.role = params[:user][:role]
    end
    if @user.save
      flash[:notice] = "Successfully updated profile."
      redirect_to params[:last_url] || studies_url
    else
      render :action => 'edit'
    end
  end
end
