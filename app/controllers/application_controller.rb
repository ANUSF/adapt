class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery

  forbid_everything # -- forbid all access not explicitly granted

  filter_parameter_logging(:password, :password_confirmation,
                           :authenticity_token)
  
  before_filter :validate_ip

  helper_method :current_user
  
  private
  
  def login(user)
    session[:user_id] = user.id
  end

  def logout
    session[:user_id] = nil
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = User.find_by_id(session[:user_id])
  end

  def validate_ip
    if ENV["ADAPT_IS_LOCAL"] == "true" and request.remote_ip != "127.0.0.1"
      fail_with "Remote access denied."
    end
  end

  def fail_with(message)
      flash.now[:error] = message
      render :text => '', :layout => true
  end
end
