class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery

  filter_parameter_logging(:password, :password_confirmation,
                           :authenticity_token)
  
  before_filter :validate_ip

  helper_method :current_user
  
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
end
