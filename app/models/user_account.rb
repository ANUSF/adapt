class UserAccount < ActiveRecord::Base
  devise :openid_authenticatable

  def self.build_from_identity_url(identity_url)
    new :identity_url => identity_url
  end

  def self.openid_optional_fields
    ['http://axschema.org/contact/email',
     'http://axschema.org/namePerson/prefix',
     'http://axschema.org/namePerson/first',
     'http://axschema.org/namePerson/last',
     'http://axschema.org/namePerson/suffix',
     'http://users.ada.edu.au/role']
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
      when 'http://users.ada.edu.au/role'          then self.role     = value
      else
        Rails.logger.error "Unknown OpenID field: #{key} => #{value}"
      end
    end

    self.name = [name[:prefix], name[:first], name[:last], name[:suffix]
                ].compact.join ' '
  end
end
