# The controller for establishing and destroying user sessions, or in
# other words, to handle authentication and login/logout. This
# controller accepts OpenID's from a single provider as the only valid
# form of authentication.

class UserSessionsController < ApplicationController
  # -- the OpenID provider we accept
  OPENID_SERVER = ADAPT::CONFIG['assda.openid.server']
  OPENID_LOGOUT = ADAPT::CONFIG['assda.openid.logout']

  # -- declare access permissions via the 'verboten' plugin
  permit :new, :create, :if => :logged_out, :message => "Already logged in."
  permit :destroy

  # ----------------------------------------------------------------------------
  # The actions this controller implements.
  # ----------------------------------------------------------------------------
  def new
  end
  
  def create
    # -- construct the OpenID URL to authenticate
    openID_url = params[:login] ? OPENID_SERVER + params[:login] : nil

    if bypass_openid
      # -- bypass server authentication for demo purposes or testing
      login_as openID_url, :message => "Demo mode: ASSDA ID was not checked."
    else
      # -- authenticate with the OpenID provider
      args = [openID_url, { :optional => ["email", "fullname"] }]
      authenticate_with_open_id(*args) do |result, ident_url, profile|
        # -- check the returned status
        if result.status == :successful
          # -- everything's fine: create a session
          login_as ident_url, :profile => profile
        else
          # -- something went wrong: display an error message
          flash.now[:error] = result.message
          render :action => 'new'
        end
      end
    end
  end
  
  def destroy
    new_session
    name = current_user ? current_user.username : ""
    flash[:notice] = params[:message] || "User #{name} logged out."

    if bypass_openid
      redirect_to login_url
    else
      # -- log out from OpenID provider (NOTE: this is specific for ASSDA server)
      back = URI.escape(root_url, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
      redirect_to OPENID_LOGOUT + "?return_url=#{back}"
    end
  end

  # ----------------------------------------------------------------------------
  # Private helper methods.
  # ----------------------------------------------------------------------------
  private

  # Creates a session with the given identity as the authenticated user.
  def login_as(ident_url, options = {})
    # -- strip the server address and create a user record if none exist
    login_name = ident_url.sub(/^#{OPENID_SERVER}/, '')
    user = User.find_or_create_by_username(login_name)

    # -- fill in user data from the OpenID simple registration profile received
    unless user.nil?
      profile = options[:profile] || {}
      user.role  = "contributor"       if user.role.blank?
      user.name  = profile["fullname"] unless profile["fullname"].blank?
      user.email = profile["email"]    unless profile["email"].blank?
      user.openid_identifier = ident_url
      user.save!
    end

    # -- create a new session for the given user
    if user && new_session(user)
      flash[:notice] = options[:message] || "Login successful."
      redirect_to studies_url
    else
      flash.now[:error] = "Sorry, something went wrong. Please try again later!"
      render :action => 'new'
    end
  end
end
