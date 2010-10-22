# The base controller class from which all other controllers inherit.
#
# (c)2010 ANUSF

class ApplicationController < ActionController::Base
  unless ActionController::Base.consider_all_requests_local
    rescue_from Exception,                            :with => :render_error
    rescue_from ActiveRecord::RecordNotFound,         :with => :render_not_found
    rescue_from ActionController::RoutingError,       :with => :render_not_found
    rescue_from ActionController::UnknownController,  :with => :render_not_found
    rescue_from ActionController::UnknownAction,      :with => :render_not_found
  end

  # -- the standard layout
  layout ADAPT::CONFIG['adapt.layout'] || 'application'

  # -- makes all helpers available in controllers
  helper :all

  # -- makes these controller methods available in views
  helper_method :current_user, :in_demo_mode, :users_may_change_roles
 
  # -- forbids all access not explicitly granted ('verboten' plugin)
  forbid_everything

  # -- protects from CSRF attacks via an authenticity token
  protect_from_forgery
  filter_parameter_logging :authenticity_token, :licence_text

  # -- this handles session expiration, invalid IP addresses, etc.
  around_filter :validate_session

  
  private

  def render_not_found(exception)
    Rails.logger.error(exception)
    @exception = exception
    render :template => "/errors/404.html.haml", :status => 404
  end

  def render_error(exception)
    Rails.logger.error(exception)
    @exception = exception
    render :template => "/errors/500.html.haml", :status => 500
    unless Rails.env == 'development'
      UserMailer.deliver_error_notification(exception)
    end
  end

  # Returns the current date as a nicely formatted string
  def current_date
    Date.today.strftime("%d %B %Y")
  end

  # The logged in user for the current session, or nil if none.
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = User.find_by_id(session[:user_id])
  end

  # Whether the application is being run in a special demo mode.
  def in_demo_mode
    Rails.env != 'production'
  end

  # Whether the application is being run locally on the user's machine
  def in_local_mode
    Rails.env == 'local' or ADAPT::CONFIG['adapt.is.local']
  end

  # Whether users may assume arbitrary roles.
  def users_may_change_roles
    in_demo_mode
  end

  # Whether to bypass OpenID verification.
  def bypass_openid
    %{development test cucumber}.include?(Rails.env) or in_local_mode
  end

  # Starts a new session in which the given user is logged in.
  def new_session(user = nil)
    reset_session
    session[:user_id] = user && user.id
    session[:ip] = request.remote_ip
  end

  # Forced logout for current user.
  def kill_session(message)
    redirect_to logout_url(:message => message + " Please log in again!")
  end

  def local_request?
    request.remote_ip == "127.0.0.1"
  end

  # This is called as an around filter for all controller actions and
  # handles session expiration, invalid IP addresses, etc.
  def validate_session
    if in_local_mode
      # -- local instances can not be accessed from other host
      if request.remote_ip != "127.0.0.1"
        flash.now[:error] = "Remote access denied."
        render :text => '', :layout => true
      end
    elsif current_user
      # -- if someone is logged in, check some things
      begin
        SessionInfo.current_user = current_user
        SessionInfo.request_host = request.host_with_port
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
