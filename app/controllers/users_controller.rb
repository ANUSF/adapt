class UsersController < ApplicationController
  permit :edit, :update, :if => :logged_in

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
      redirect_to studies_url
    else
      render :action => 'edit'
    end
  end
end
