# All Adapt-specific controllers inherit from this one.
#
# (c)2010 ANUSF

class Adapt::Controller < ApplicationController
  # -- forbids all access not explicitly granted ('verboten' plugin)
  include Verboten

  # -- makes some controller methods available in views
  helper_method :current_user

  # -- store some info
  before_filter :store_session_info

  private

  # The logged in user for the current session, or nil if none.
  def current_user
    unless session[:adapt_roles_files_was_read]
      process_roles_file
      session[:adapt_roles_files_was_read] = true
    end

    if not defined?(@current_user) and user_account_signed_in? and
        current_user_account.identity_url
      # -- create an ADAPT user entry from scratch
      identifier = current_user_account.identity_url
      username = identifier.sub(/^#{ADAPT::CONFIG['assda.openid.server']}/, '')
      user = Adapt::User.find_by_username(username)
      unless user
        user = Adapt::User.new(:name  => current_user_account.name,
                               :email => current_user_account.email)
        user.openid_identifier = identifier
        user.username = username
        user.role = "contributor"
        user.save!
      end
      @current_user = user
    end
    @current_user
  end

  def store_session_info
    Adapt::SessionInfo.current_user = current_user
    Adapt::SessionInfo.request_host = request.host_with_port
  end

  def process_roles_file
    unless %w{test cucumber}.include? Rails.env
      roles_file = File.join(ADAPT::CONFIG['adapt.config.path'],
                             'roles.properties')
      if File.exist?(roles_file)
        names = []
        for line in File.open(roles_file, &:read).split("\n")
          unless line.strip.blank? or line.strip.starts_with?('#')
            fields = line.split(',').map do |s|
              s.sub /^\s*"\s*(.*\S)\s*"\s*$/, '\1'
            end
            username, firstname, lastname, email, role = fields
            role = case role
                   when 'publisher'     then 'archivist'
                   when 'administrator' then 'admin'
                   else                      'contributor'
                   end
            user = Adapt::User.find_or_create_by_username username
            user.name = "#{firstname} #{lastname}"
            user.email = email
            user.role = role
            user.save!
            names << username
          end
        end
        unless names.empty?
          Adapt::User.all.each do |user|
            if user.role != 'contributor' and not names.include?(user.username)
              user.role = 'contributor'
              user.save!
            end
          end
        end
      end
    end
  end
end
