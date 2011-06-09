class ApplicationController < ActionController::Base
  layout 'ada' unless ADAPT::CONFIG['adapt.theme.old']

  include Devise::Controllers::Helpers
  include OpenidClient::Helpers

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
  before_filter :update_authentication
  before_filter :store_session_info
  before_filter :set_asset_host

  private

  def set_asset_host
    ActionController::Base.asset_host = root_url
  end

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
end
