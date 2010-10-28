# All Adapt-specific controllers inherit from this one.
#
# (c)2010 ANUSF

class Adapt::Controller < ApplicationController
  # -- the standard layout
  layout ADAPT::CONFIG['adapt.layout'] || 'application'

  # -- forbids all access not explicitly granted ('verboten' plugin)
  include Verboten

  # -- makes some controller methods available in views
  helper_method :current_user

  # -- store some info
  before_filter :store_session_info

  private

  # The logged in user for the current session, or nil if none.
  def current_user
    current_user_account
  end

  def store_session_info
    Adapt::SessionInfo.current_user = current_user
    Adapt::SessionInfo.request_host = request.host_with_port
  end
end
