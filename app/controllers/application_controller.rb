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
    state = load_oid_state
    Rails.logger.error "@@@ oid_state = #{state.inspect}"
    if openid_current?(state)
      unless state['request_url'].blank?
        request_url = state['request_url']
        state['request_url'] = nil
        save_oid_state state
        redirect_to request_url
      end
    elsif state['checking'].blank?
      state['request_url'] = request.url
      state['checking'] = true
      reset_session
      save_oid_state state
      redirect_to new_user_session_path(:user => { :immediate => true })
    else
      save_oid_state state
    end
  end

  def openid_current?(state)
    if not session[:openid_checked].blank?
      state['checking'] = nil
      timestamp = cookies[:_openid_session_timestamp]
      if timestamp.blank? or timestamp == state['server_timestamp']
        true
      else
        state['server_timestamp'] = timestamp
        session[:openid_checked] = nil
        false
      end
    else
      false
    end
  end

  OID_STATE_KEY = "_#{Rails.root.sub(/^.*\//, '')}_oid_state"

  def load_oid_state
    JSON::load(cookies[OID_STATE_KEY] || '{}')
  end

  def save_oid_state(state)
    cookies[OID_STATE_KEY] = state.to_json
  end
end
