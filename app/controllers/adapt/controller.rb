# All Adapt-specific controllers inherit from this one.
#
# (c)2010 ANUSF

class Adapt::Controller < ApplicationController
  # -- the standard layout
  layout ADAPT::CONFIG['adapt.layout'] || 'application'

  # -- forbids all access not explicitly granted ('verboten' plugin)
  include Verboten

  before_filter :store_session_info

  private

  def store_session_info
    Adapt::SessionInfo.current_user = current_user
    Adapt::SessionInfo.request_host = request.host_with_port
  end
end
