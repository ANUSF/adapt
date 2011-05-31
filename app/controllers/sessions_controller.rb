class SessionsController < OpenidClient::SessionsController
  DEFAULT_SERVER=ADAPT::CONFIG['ada.openid.server']

  permit :new, :create, :destroy
  permit :update do users_may_change_roles and logged_in end

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

  protected

  def force_default?
    true
  end

  def default_login
    DEFAULT_SERVER
  end

  def logout_url_for(identity)
    if identity and identity.starts_with? DEFAULT_SERVER
      "#{DEFAULT_SERVER}/logout"
    else
      nil
    end
  end
end
