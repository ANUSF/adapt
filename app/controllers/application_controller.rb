class ApplicationController < ActionController::Base
  layout 'ada' unless ADAPT::CONFIG['adapt.theme.old']

  include Devise::Controllers::Helpers

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception,                           :with => :render_error
    rescue_from ActiveRecord::RecordNotFound,        :with => :render_not_found
    rescue_from ActionController::RoutingError,      :with => :render_not_found
    rescue_from ActionController::UnknownController, :with => :render_not_found
    rescue_from ActionController::UnknownAction,     :with => :render_not_found
  end

  # -- forbids all access not explicitly granted ('verboten' plugin)
  include Verboten

  # -- makes some controller methods available in views
  helper_method :current_user, :in_demo_mode, :users_may_change_roles

  # -- makes all helpers available in controllers
  helper :all

  # -- protects from CSRF attacks via an authenticity token
  protect_from_forgery

  # -- before filters
  before_filter :check_session
  before_filter :store_session_info

  
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
    not %w{production staff stage}.include? Rails.env
  end

  # Whether users may assume arbitrary roles.
  def users_may_change_roles
    in_demo_mode
  end

  def store_session_info
    Adapt::SessionInfo.current_user = current_user
    Adapt::SessionInfo.request_host = request.host_with_port
  end

  # Redirects to a requested page after authentication; checks whether
  # user is already authenticated against a single-sign-on server
  # otherwise.
  def check_session
    if openid_current?
      unless cookies[:_adapt_requested_url].blank?
        requested_url = cookies[:_adapt_requested_url]
        cookies[:_adapt_requested_url] = nil
        redirect_to requested_url
      end
    elsif cookies[:_adapt_checking_openid].blank?
      cookies[:_adapt_requested_url] = request.url
      cookies[:_adapt_checking_openid] = true
      reset_session
      redirect_to new_user_session_path(:user => { :immediate => true })
    end
  end

  def openid_current?
    if not session[:openid_checked].blank?
      cookies[:_adapt_checking_openid] = nil
      oid_timestamp = cookies[:_openid_session_timestamp]
      our_timestamp = cookies[:_adapt_openid_timestamp]
      if oid_timestamp.blank? or oid_timestamp == our_timestamp
        true
      else
        cookies[:_adapt_openid_timestamp] = oid_timestamp
        session[:openid_checked] = nil
        false
      end
    else
      false
    end
  end
end
