class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :current_user, :users_may_change_roles
  
  around_filter :validate_session
  forbid_everything # forbid all access not explicitly granted

  protect_from_forgery
  filter_parameter_logging :authenticity_token
  
  private
  
  def login(user)
    new_session(user)
  end

  def logout
    new_session
  end

  def new_session(user = nil)
    reset_session
    session[:user_id] = user && user.id
    session[:ip] = request.remote_ip
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = User.find_by_id(session[:user_id])
  end

  def users_may_change_roles
    Rails.env == 'development' or ENV["ADAPT_IS_LOCAL"] == "true"
  end

  def validate_session
    if ENV["ADAPT_IS_LOCAL"] == "true"
      if request.remote_ip != "127.0.0.1"
        flash.now[:error] = "Remote access denied."
        render :text => '', :layout => true
      end
    elsif current_user
      begin
        if request.remote_ip != session[:ip]
          kill_session "Your network connection seems to have changed."
        elsif !session[:expires_at] or session[:expires_at] < Time.now
          kill_session "Your session has expired."
        end
      rescue ActiveRecord::RecordNotFound # stale session cookie
        kill_session "You seem to have a stale session cookie."
      end
    end

    yield

    session[:expires_at] = 1.hour.since
  end

  def kill_session(message)
    new_session
    flash[:error] = message + " Please log in again!"
    redirect_to login_url
  end
end
