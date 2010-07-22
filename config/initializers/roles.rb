unless %w{test cucumber}.include? Rails.env
  roles_file = File.join(ADAPT::CONFIG['adapt.config.path'], 'roles.properties')
  if File.exist?(roles_file)
    names = []
    for line in File.open(roles_file, &:read).split("\n")
      unless line.strip.blank? or line.strip.starts_with?('#')
        fields = line.split(',').map { |s| s.sub /^\s*"\s*(.*\S)\s*"\s*$/, '\1' }
        username, firstname, lastname, email, role = fields
        role = case role
               when 'publisher'     then 'archivist'
               when 'administrator' then 'admin'
               else                      'contributor'
               end
        user = User.find_or_create_by_username username
        user.name = "#{firstname} #{lastname}"
        user.email = email
        user.role = role
        user.save!
        names << username
      end
    end
    obsolete = User.all.select { |user| not names.include?(user.username) }.to_a
    obsolete.each { |user| user.destroy }
  end
end
