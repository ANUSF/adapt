class User < ActiveRecord::Base
  devise :openid_authenticatable

  has_many :studies, :dependent => :destroy, :class_name => 'Adapt::Study'
  has_many :studies_in_curation,  :class_name  => 'Adapt::Study',
  :foreign_key => :archivist_id

  attr_accessible(:email, :name, :address, :telephone, :fax)

  scope :archivists, :conditions => { :role => 'archivist' }
  scope :admins,     :conditions => { :role => 'admin' }

  # -- the possible roles for a user
  ROLES = %w{contributor archivist admin}

  # -- patterns for checking phone numbers
  SEP   = /( |-)?/
  WORLD = / \+\d{1,3} #{SEP} (\d|\(\d\)) #{SEP} \d{1,5} /xo
  AREA  = / \d{2,6} | \(\d{2,6}\) /xo
  LINE  = / \d{2,4} #{SEP} \d{4} /xo
  EXT   = /#{SEP}(ext|x)#{SEP}\d{1,5}/xo
  PHONE = /\A ((#{WORLD}|#{AREA}) #{SEP} #{LINE} #{EXT}?)? \Z/xo

  validates_format_of   :telephone, :with => PHONE,
  :message => "Does not look like a phone number."
  validates_format_of   :fax, :with => PHONE,
  :message => "Does not look like a phone number."

  def selections(column)
    ROLES if column.to_sym == :role
  end

  def is_archivist
    %w{archivist admin}.include? role
  end

  def is_admin
    role == 'admin'
  end

  alias_method :admin?, :is_admin

  def self.build_from_identity_url(identity_url)
    user = new
    user.identity_url = identity_url
    user
  end

  def self.openid_optional_fields
    ['http://axschema.org/contact/email',
     'http://axschema.org/namePerson/prefix',
     'http://axschema.org/namePerson/first',
     'http://axschema.org/namePerson/last',
     'http://axschema.org/namePerson/suffix',
     'http://users.ada.edu.au/role']
  end

  def self.map_role(role)
    case role
    when 'publisher', 'archivist', 'approver' then 'archivist'
    when 'administrator', 'manager'           then 'admin'
    else                                           'contributor'
    end
  end

  def openid_fields=(fields)
    name = {}

    fields.each do |key, value|
      # Some AX providers can return multiple values per key
      value = value.first if value.is_a? Array

      case key.to_s
      when 'http://axschema.org/namePerson/prefix' then name[:prefix] = value
      when 'http://axschema.org/namePerson/first'  then name[:first]  = value
      when 'http://axschema.org/namePerson/last'   then name[:last]   = value
      when 'http://axschema.org/namePerson/suffix' then name[:suffix] = value
      when 'http://axschema.org/contact/email'     then self.email    = value
      when 'http://users.ada.edu.au/role'
        self.role = self.class.map_role value
      else
        Rails.logger.error "Unknown OpenID field: #{key} => #{value}"
      end
    end

    self.username = identity_url.sub /^.*\//, ''

    self.name = [name[:prefix], name[:first], name[:last], name[:suffix]
                ].compact.join ' '

    save! if self.changed?
  end
end
