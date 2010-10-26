# The controller for establishing and destroying user sessions, or in
# other words, to handle authentication and login/logout. This
# controller accepts OpenID's from a single provider as the only valid
# form of authentication.

class Adapt::UserSessionsController < Adapt::ApplicationController
  # -- the OpenID provider we accept
  OPENID_SERVER = ADAPT::CONFIG['assda.openid.server']
  OPENID_LOGOUT = ADAPT::CONFIG['assda.openid.logout']

  # -- declare access permissions via the 'verboten' plugin
  permit :new, :create, :if => :logged_out, :message => "Already logged in."
  permit :destroy
  permit :update do users_may_change_roles and logged_in end

  # ----------------------------------------------------------------------------
  # The actions this controller implements.
  # ----------------------------------------------------------------------------
  def new
  end
  
  def create
    process_roles_file

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

  def update
    @user = current_user
    if @user and params[:adapt_user][:role]
      @user.role = params[:adapt_user][:role]
      if @user.save
        flash[:notice] = "Successfully changed role."
      else
        flash[:error] = "Error in role change."
      end
      redirect_to params[:last_url] || adapt_studies_url
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
      redirect_to adapt_studies_url
    else
      flash.now[:error] = "Sorry, something went wrong. Please try again later!"
      render :action => 'new'
    end
  end

  def process_roles_file
    unless %w{test cucumber}.include? Rails.env
      roles_file = File.join(ADAPT::CONFIG['adapt.config.path'],
                             'roles.properties')
      if File.exist?(roles_file)
        names = []
        for line in File.open(roles_file, &:read).split("\n")
          unless line.strip.blank? or line.strip.starts_with?('#')
            fields = line.split(',').map do |s|
              s.sub /^\s*"\s*(.*\S)\s*"\s*$/, '\1'
            end
            username, firstname, lastname, email, role = fields
            role = case role
                   when 'publisher'     then 'archivist'
                   when 'administrator' then 'admin'
                   else                      'contributor'
                   end
            user = User.find_or_create_by_username username
            user.name = "#{firstname} #{lastname}"
            user.email = email
            user.role = role
            user.save!
            names << username
          end
        end
        unless names.empty?
          User.all.each do |user|
            if user.role != 'contributor' and not names.include?(user.username)
              user.role = 'contributor'
              user.save!
            end
          end
        end
      end
    end
  end
end
