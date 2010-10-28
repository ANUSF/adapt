class ApplicationController < ActionController::Base
  helper_method :current_user, :in_demo_mode, :users_may_change_roles

  def current_user #placeholder, to be defined in devise controller
  end

  # Whether the application is being run in a special demo mode.
  def in_demo_mode
    Rails.env != 'production'
  end

  # Whether users may assume arbitrary roles.
  def users_may_change_roles
    in_demo_mode
  end
end
