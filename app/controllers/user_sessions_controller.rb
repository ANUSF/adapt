class UserSessionsController < ApplicationController
  OPENID_SERVER = ENV['ASSDA_OPENID_SERVER']

  permit :new, :create, :if => :logged_out, :message => "Already logged in."
  permit :destroy, :if => :logged_in, :message => "Already logged out."

  def new
  end
  
  def create
    openID_url = params[:login] ? OPENID_SERVER + params[:login] : nil

    if bypass_openid
      login_as openID_url, :message => "Demo mode: ASSDA ID was not checked."
    else
      args = [openID_url, { :optional => ["email", "fullname"] }]
      authenticate_with_open_id(*args) do |result, ident_url, profile|
        if result.status == :successful
          Rails.logger.info(profile.inspect)
          login_as ident_url, :profile => profile
        else
          flash.now[:error] = result.message
          render :action => 'new'
        end
      end
    end
  end
  
  def destroy
    new_session
    flash[:notice] = "Successfully logged out."
    redirect_to root_url
  end

  private

  def login_as(ident_url, options = {})
    login_name = ident_url.sub(/^#{OPENID_SERVER}/, '')
    user = User.find_or_create_by_username(login_name)
    unless user.nil?
      profile = options[:profile] || {}
      user.role  = "contributor"       if user.role.blank?
      user.name  = profile["fullname"] unless profile["fullname"].blank?
      user.email = profile["email"]    unless profile["email"].blank?
      user.openid_identifier = ident_url
      user.save!
    end

    if user && new_session(user)
      flash[:notice] = options[:message] || "Login successful."
      redirect_to studies_url
    else
      flash.now[:error] = "Sorry, something went wrong. Please try again later!"
      render :action => 'new'
    end
  end
end
