class UserSessionsController < ApplicationController
  ASSDA_OPENID_PATH = "http://wyrd.anu.edu.au:8080/joid/user/"

  permit :new, :create, :if => :logged_out, :message => "Already logged in."
  permit :destroy, :if => :logged_in, :message => "Already logged out."

  def new
  end
  
  def create
    openID_url = params[:login] ? ASSDA_OPENID_PATH + params[:login] : nil

    authenticate_with_open_id(openID_url) do |result, ident_url|
      case result.status
      when :missing
        failed_login "Sorry, the OpenID server couldn't be found"
      when :invalid
        failed_login "Sorry, this seems to be an invalid OpenID"
      when :canceled
        failed_login "OpenID verification was canceled"
      when :failed
        failed_login "Sorry, the OpenID verification failed"
      when :successful
        if login_as ident_url
          flash[:notice] = "Login successful."
          redirect_to studies_url
        else
          failed_login
        end
      end
    end
  end
  
  def destroy
    logout
    flash[:notice] = "Successfully logged out."
    redirect_to root_url
  end

  private

  def login_as(ident_url)
    user = User.find_by_openid_identifier(ident_url)
    if user.nil?
      login_name = ident_url.sub(/^#{ASSDA_OPENID_PATH}/, '')
      name = case login_name
             when /([a-z]+)\.([a-z]+)/i
               "#{$1.capitalize} #{$2.capitalize}"
             else
               login_name
             end
      user = User.new(:username => login_name, :name => name)
      user.openid_identifier = ident_url
      user.save!
    end
    user && login(user)
  end

  def failed_login(message)
    flash.now[:error] = message || "Login failed."
    render :action => 'new'
  end
end
