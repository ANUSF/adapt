class ApplicationController < ActionController::Base
  include Devise::Controllers::Helpers

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception,                           :with => :render_error
    rescue_from ActiveRecord::RecordNotFound,        :with => :render_not_found
    rescue_from ActionController::RoutingError,      :with => :render_not_found
    rescue_from ActionController::UnknownController, :with => :render_not_found
    rescue_from ActionController::UnknownAction,     :with => :render_not_found
  end

  # -- makes some controller methods available in views
  helper_method :current_user_account, :in_demo_mode, :users_may_change_roles

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
      Adapt::UserMailer.error_notification(exception).deliver
    end
  end

  # Returns the current date as a nicely formatted string
  def current_date
    Date.today.strftime("%d %B %Y")
  end

  # Whether the application is being run in a special demo mode.
  def in_demo_mode
    Rails.env != 'production'
  end

  # Whether users may assume arbitrary roles.
  def users_may_change_roles
    in_demo_mode
  end

  # This is called as an around filter for all controller actions and
  # handles session expiration, invalid IP addresses, etc.
  def validate_session
    # -- if someone is logged in, make sure the session is still valid
    error = warden.user(:user_account) && check_session

    if error
      # -- close the current session and report the error
      sign_out(:user_account)
      reset_session
      flash.now[:error] = error + ' Please log in again.'
      render :text => '', :layout => true
    else
      # -- no error: call the intended controller action
      yield
    end

    # -- the session will expire after two hours of inactivity
    session[:expires_at] = 2.hours.since
  end

  # Performs some tests to see if a login session is still valid.
  def check_session
    session[:ip] ||= request.remote_ip
    if request.remote_ip != session[:ip]
      'Your network connection seems to have changed.'
    elsif !session[:expires_at] or session[:expires_at] < Time.now
      'Your session has expired.'
    end
  rescue ActiveRecord::RecordNotFound
    'You seem to have a stale session cookie.'
  end
end
