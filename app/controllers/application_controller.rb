class ApplicationController < ActionController::Base
  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception,                           :with => :render_error
    rescue_from ActiveRecord::RecordNotFound,        :with => :render_not_found
    rescue_from ActionController::RoutingError,      :with => :render_not_found
    rescue_from ActionController::UnknownController, :with => :render_not_found
    rescue_from ActionController::UnknownAction,     :with => :render_not_found
  end

  # -- makes some controller methods available in views
  helper_method :current_user, :in_demo_mode, :users_may_change_roles

  # -- makes all helpers available in controllers
  helper :all

  # -- protects from CSRF attacks via an authenticity token
  protect_from_forgery

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

  # # The logged in user for the current session, or nil if none.
  def current_user
    current_user_account
  end

  # Whether the application is being run in a special demo mode.
  def in_demo_mode
    Rails.env != 'production'
  end

  # Whether users may assume arbitrary roles.
  def users_may_change_roles
    in_demo_mode
  end

  # Whether to bypass OpenID verification.
  def bypass_openid
    %{development test cucumber}.include?(Rails.env)
  end

  # Forced logout for current user.
  def kill_session(message)
    redirect_to destroy_user_account_session(:message =>
                                             message + " Please log in again!")
  end

  def local_request?
    request.remote_ip == "127.0.0.1"
  end

  # This is called as an around filter for all controller actions and
  # handles session expiration, invalid IP addresses, etc.
  def validate_session
    if current_user
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
