class UserSessionsController < ApplicationController
  OPENID_SERVER = ENV['ASSDA_OPENID_SERVER']

  permit :new, :create, :if => :logged_out, :message => "Already logged in."
  permit :destroy, :if => :logged_in, :message => "Already logged out."

  def new
  end
  
  def create
    openID_url = params[:login] ? OPENID_SERVER + params[:login] : nil

    if bypass_openid
      login_as openID_url, "Demo mode: ASSDA ID was not checked."
    else
      #sreg = ["email", "fullname"]
      sreg = []
      authenticate_with_open_id(openID_url, :optional => sreg) do
        |result, ident_url, profile|

        if result.status == :successful
          Rails.logger.info(profile.inspect)
          login_as ident_url
        else
          failed_login result.message
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

  def login_as(ident_url, message = nil)
    user = User.find_by_openid_identifier(ident_url)
    if user.nil?
      login_name = ident_url.sub(/^#{OPENID_SERVER}/, '')
      name = case login_name
             when /([a-z]+)\.([a-z]+)/i
               "#{$1.capitalize} #{$2.capitalize}"
             else
               login_name
             end
      user = User.new(:username => login_name, :name => name)
      user.openid_identifier = ident_url
      user.role = "contributor"
      user.save!
    end
    if user && login(user)
      flash[:notice] = message || "Login successful."
      redirect_to studies_url
    else
      failed_login
    end
  end

  def failed_login(message = nil)
    flash.now[:error] = message || "Login failed."
    render :action => 'new'
  end
end
