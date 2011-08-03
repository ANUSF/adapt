OpenidClient::Config.configure do |c|
  c.re_authenticate_after =
    ADAPT::CONFIG['ada.openid.expiration'].to_i || 15.minutes
  c.client_state_key        = :_adapt_openid_client_state
  c.session_controller_name = 'sessions'
end
