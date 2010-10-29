class SessionsController < Devise::SessionsController
  OPENID_SERVER = ADAPT::CONFIG['assda.openid.server']
  OPENID_LOGOUT = ADAPT::CONFIG['assda.openid.logout']

  def create
    login = params[resource_name][:identity_url]

    # -- allow users to log in with just their ASSDA names
    unless login.starts_with?('http://')
      login = params[resource_name][:identity_url] = OPENID_SERVER + login
    end

    if bypass_openid
      resource_class = resource_name.to_s.classify.constantize
      resource = resource_class.find_or_create_by_identity_url(login)
    else
      resource = warden.authenticate!(:scope => resource_name, :recall => "new")
    end

    set_flash_message :notice, :signed_in
    sign_in_and_redirect(resource_name, resource)
  end

  def destroy
    # -- sign out via devise without redirecting
    set_flash_message :notice, :signed_out if signed_in?(resource_name)
    sign_out(resource_name)

    if bypass_openid
      redirect_to root_url
    else
      # -- log out from OpenID provider (NOTE: this is specific for ASSDA server)
      back = URI.escape(root_url, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
      redirect_to OPENID_LOGOUT + "?return_url=#{back}"
    end
  end

  private

  # Whether to bypass OpenID verification.
  def bypass_openid
    [
     'development',
     'test',
     'cucumber'
    ].include?(Rails.env)
  end
end
