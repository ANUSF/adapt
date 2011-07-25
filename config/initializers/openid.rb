OpenidClient::Config.configure do |c|
  c.re_authenticate_after =
    ADAPT::CONFIG['ada.openid.expiration'].to_i || 15.minutes
end
