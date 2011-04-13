class SessionsController < OpenidClient::SessionsController
  TESTADA='http://178.79.149.181:3000'

  protected

  def force_default?
    true
  end

  def default_login
    TESTADA
  end

  def logout_url_for(identity)
    if identity and identity.starts_with? TESTADA
      "#{TESTADA}/logout"
    else
      nil
    end
  end
end
