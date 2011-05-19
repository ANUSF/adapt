class SessionsController < OpenidClient::SessionsController
  DEFAULT_SERVER=ENV['ADA_OID'] || 'http://users-test.ada.edu.au'

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
