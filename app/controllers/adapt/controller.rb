# All Adapt-specific controllers inherit from this one.
#
# (c)2010 ANUSF

class Adapt::Controller < ApplicationController
  # -- forbids all access not explicitly granted ('verboten' plugin)
  include Verboten

  # -- makes some controller methods available in views
  helper_method :current_user

  # -- store some info
  before_filter :store_session_info

  private

  # The logged in user for the current session, or nil if none.
  def current_user
    if not defined?(@current_user) and user_account_signed_in? and
        current_user_account.identity_url
      # -- create an ADAPT user entry from scratch
      identifier = current_user_account.identity_url
      username = identifier.sub(/^#{ADAPT::CONFIG['ada.openid.server']}/, '')
      user = Adapt::User.find_by_username(username)
      unless user
        user = Adapt::User.new(:name  => current_user_account.name,
                               :email => current_user_account.email)
        user.openid_identifier = identifier
        user.username = username
        user.role = case current_user_account.role
                    when 'publisher'     then 'archivist'
                    when 'administrator' then 'admin'
                    else                      'contributor'
                    end
        user.save!
      end
      @current_user = user
    end
    @current_user
  end

  def store_session_info
    Adapt::SessionInfo.current_user = current_user
    Adapt::SessionInfo.request_host = request.host_with_port
  end
end
