class SessionsController < OpenidClient::SessionsController
  protected

  def force_default?
    true
  end

  def default_login
    'http://openid.assda.edu.au/joid/user/olaf.delgado'
  end

  def logout_url_for(identity)
    if identity and identity.starts_with? 'http://openid.assda.edu.au/joid/user/'
      'http://openid.assda.edu.au/joid/logout.jsp'
    else
      nil
    end
  end

  def server_human_name
    'ASSDA'
  end

  def bypass_openid?
    [
     'development',
     'test',
     'cucumber'
    ].include?(Rails.env) and not ENV['FORCE_OPENID']
  end
end
