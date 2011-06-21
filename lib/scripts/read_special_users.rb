require 'httparty'
require 'highline'

SERVER_BASE = ADAPT::CONFIG['ada.openid.server']

def update_users(data)
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
end


class Server
  include HTTParty

  def initialize(user = nil, pass = nil)
    self.class.basic_auth(user, pass) unless user.nil?
  end

  def get(*args)
    self.class.get *args
  end
end

use_basic_auth = true
server_uri = "#{SERVER_BASE}/users/privileged?api_key=#{Secrets::API_KEY}"

if use_basic_auth
  puts "HTTP authentication needed for #{SERVER_BASE}"
  h = HighLine.new
  user = h.ask("User: ")
  pass = h.ask("Password: ") { |q| q.echo = '*' }
  server = Server.new user, pass
else
  server = Server.new
end

data = JSON::load server.get(server_uri).body

update_users data
