class UserSessionsController < ApplicationController
  permit :new, :create, :if => :logged_out, :message => "Already logged in."
  permit :destroy, :if => :logged_in, :message => "Already logged out."

  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    @user_session.save do |successful|
      if successful
        flash[:notice] = "Welcome #{@user_session.record.username}!"
        redirect_to studies_url
      else
        flash.now[:error] = "Login failed."
        render :action => 'new'
      end
    end
  end
  
  def destroy
    @user_session = UserSession.find
    if @user_session
      @user_session.destroy
      flash[:notice] = "Successfully logged out."
    end
    redirect_to root_url
  end
end
