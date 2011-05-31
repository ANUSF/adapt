class OpenidClient::SessionsController
  def new
    resource_class = resource_name.to_s.classify.constantize
    resource = resource_class.find_or_create_by_identity_url(params[:user])

    session[:openid_checked] = true
    set_flash_message :notice, :signed_in
    sign_in_and_redirect(resource_name, resource)
  end

  def destroy
    if signed_in?(resource_name)
      sign_out(resource_name)
      set_flash_message :notice, :signed_out
    end
    
    if (params[resource_name] || {})[:immediate]
      session[:openid_checked] = true
    end
    redirect_to root_url
  end
end
