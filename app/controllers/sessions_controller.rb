class SessionsController < Devise::SessionsController
  #TODO provide a way to bypass authentication for easier testing

  OPENID_SERVER = ADAPT::CONFIG['assda.openid.server']
  OPENID_LOGOUT = ADAPT::CONFIG['assda.openid.logout']

  def create
    # -- rewrite the identity url so ASSDA users can log in with just their name
    url = params[resource_name][:identity_url]
    unless url.starts_with?(OPENID_SERVER)
      params[resource_name][:identity_url] = OPENID_SERVER + url
    end

    # -- call the default action
    super
  end

  def destroy
    # -- sign out via devise without redirecting
    set_flash_message :notice, :signed_out if signed_in?(resource_name)
    sign_out(resource_name)

    # -- log out from OpenID provider (NOTE: this is specific for ASSDA server)
    back = URI.escape(root_url, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    redirect_to OPENID_LOGOUT + "?return_url=#{back}"
  end
end
