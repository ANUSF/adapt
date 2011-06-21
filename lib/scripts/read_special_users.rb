require 'httparty'

SERVER_BASE = ADAPT::CONFIG['ada.openid.server']

server_uri = "#{SERVER_BASE}/users/privileged?api_key=#{Secrets::API_KEY}"

data = JSON::load HTTParty.get(server_uri).body

User.transaction do
  User.all.each { |u|
    u.role = "contributor"
    u.save!
  }

  data.each { |e|
    url = "#{SERVER_BASE}/user/#{e['user']}"
    u = User.find_or_create_by_identity_url url
    u.username = e['user']
    
    name = [e['fname'], e['sname']].compact.join ' '
    u.name = if name.blank?
               u.username.split('.').map(&:capitalize).join ' '
             else
               name
             end
      
    u.email = e['email']
    u.role = case e['user_role']
             when 'publisher'     then 'archivist'
             when 'administrator' then 'admin'
             else                      'contributor'
             end
    u.save!
  }
end
