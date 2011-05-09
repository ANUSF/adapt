class UserAccount < ActiveRecord::Base
  devise :openid_authenticatable

  def self.build_from_identity_url(identity_url)
    new(:identity_url => identity_url)
  end

  def self.openid_optional_fields
    ['email', 'http://axschema.org/contact/email',
     'http://axschema.org/namePerson/first',
     'http://axschema.org/namePerson/last',
     'http://users.ada.edu.au/role'
    ]
  end

  def openid_fields=(fields)
    fields.each do |key, value|
      # Some AX providers can return multiple values per key
      if value.is_a? Array
        value = value.first
      end

      case key.to_s
      when 'fullname'
        Rails.logger.error "Known OpenID field: #{key} => #{value}"
        self.name = value
      when 'email', 'http://axschema.org/contact/email'
        Rails.logger.error "Known OpenID field: #{key} => #{value}"
        self.email = value
      else
        Rails.logger.error "Unknown OpenID field: #{key} => #{value}"
      end
    end
  end
end
