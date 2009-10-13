class UsersController < ApplicationController
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    @user.save do |successful|
      if successful
        flash[:notice] = "Registration successful."
        redirect_to studies_url
      else
        flash.now[:error] = "Registration failed."
        render :action => 'new'
      end
    end
  end
  
  def edit
    @user = current_user
  end
  
  def update
    @user = current_user
    @user.attributes = params[:user]
    @user.save do |successful|
      if successful
        flash[:notice] = "Successfully updated profile."
        redirect_to studies_url
      else
        render :action => 'edit'
      end
    end
  end
end
