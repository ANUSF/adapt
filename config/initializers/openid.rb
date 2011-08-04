OpenidClient::Config.configure do |c|
  c.re_authenticate_after   = 15.minutes
  c.client_state_key        = :_adapt_openid_client_state
  c.session_controller_name = 'sessions'
end
