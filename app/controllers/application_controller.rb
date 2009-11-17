class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery

  filter_parameter_logging(:password, :password_confirmation,
                           :authenticity_token)
  
  before_filter :validate_ip
  before_filter :authorize

  helper_method :current_user
  
  protected

  class_inheritable_accessor :permission_settings
  self.permission_settings = {}

  def self.permit(*args, &code)
    options = args.last.is_a?(Hash) ? args.pop : {}
    if block_given?
      options[:if] = code
    else
      case options[:if]
      when :logged_in  then options[:message] ||= "Must be logged in."
      when :logged_out then options[:message] ||= "Must be logged out."
      end
    end
    args.each { |name| self.permission_settings[name.to_sym] = options }
  end

  def self.before_authorization_filter(*args)
    before_filter *args
    skip_before_filter :authorize
    before_filter :authorize
  end

  def logged_in
    not logged_out
  end

  def logged_out
    current_user.nil?
  end

  private
  
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def validate_ip
    if ENV["ADAPT_IS_LOCAL"] == "true" and request.remote_ip != "127.0.0.1"
      flash.now[:error] = "Remote access denied."
      render 'layouts/empty'
    end
  end

  def authorize
    begin
      options = self.class.permission_settings[action_name.to_sym] || {}
      permitted = case options[:if]
                  when nil    then true
                  when Proc   then options[:if].call(current_user, params)
                  when Symbol then self.send(options[:if])
                  else             options[:if]
                  end
      unless permitted
        flash.now[:error] = options[:message] || "Access denied."
        render 'layouts/empty'
      end
    rescue
      flash.now[:error] = "Error in authorization check."
      render 'layouts/empty'
    end
  end
end
