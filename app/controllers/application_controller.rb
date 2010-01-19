# The base controller class from which all other controllers inherit.
#
# (c)2010 ANUSF

class ApplicationController < ActionController::Base
  # -- make all helpers available in controllers
  helper :all

  # -- make these controller methods available in views
  helper_method :current_user, :in_demo_mode, :users_may_change_roles
 
  # -- this handles session expiration, invalid IP addresses, etc.
  around_filter :validate_session

  # -- forbid all access not explicitly granted ('verboten' plugin)
  forbid_everything

  # -- protects from CSRF attacks via an authenticity token
  protect_from_forgery
  filter_parameter_logging :authenticity_token

  
  private

  # The logged in user for the current session, or nil if none.
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = User.find_by_id(session[:user_id])
  end

  # Whether the application is being run in a special demo mode.
  def in_demo_mode
    case Rails.env
    when 'development' then ENV["ADAPT_DEMO_MODE"] == 'true'
    when 'stage'       then true
    else                    false
    end
  end

  # Whether users may assume arbitrary roles.
  def users_may_change_roles
    in_demo_mode
  end

  # Whether to bypass OpenID verification.
  def bypass_openid
    in_demo_mode
  end

  # Starts a new session in which the given user is logged in.
  def new_session(user = nil)
    reset_session
    session[:user_id] = user && user.id
    session[:ip] = request.remote_ip
  end

  # Forced logout for current user.
  def kill_session(message)
    new_session
    flash[:error] = message + " Please log in again!"
    redirect_to login_url
  end

  # This is called as an around filter for all controller actions and
  # handles session expiration, invalid IP addresses, etc.
  def validate_session
    if ENV["ADAPT_IS_LOCAL"] == "true"
      # -- local instances can not be accessed from other host
      if request.remote_ip != "127.0.0.1"
        flash.now[:error] = "Remote access denied."
        render :text => '', :layout => true
      end
    elsif current_user
      # -- if someone is logged in, check some things
      begin
        # -- terminate session if expired or the IP address has changed
        if request.remote_ip != session[:ip]
          kill_session "Your network connection seems to have changed."
        elsif !session[:expires_at] or session[:expires_at] < Time.now
          kill_session "Your session has expired."
        end
      rescue ActiveRecord::RecordNotFound
        # -- handle stale session cookies
        kill_session "You seem to have a stale session cookie."
      end
    end

    # -- call the controller action
    yield

    # -- make session expire after an hour of inactivity
    session[:expires_at] = 1.hour.since
  end
end
