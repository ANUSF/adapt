class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.transition_from_crypto_providers = Authlogic::CryptoProviders::Sha512
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
    c.openid_required_fields = [:fullname, :nickname, :email]
  end
  
  attr_accessible(:username, :email, :password, :password_confirmation,
                  :name, :address, :telephone, :fax, :openid_identifier)

  # -- patterns for checking phone numbers
  SEP   = /( |-)?/
  WORLD = / \+\d{1,3} #{SEP} (\d|\(\d\)) #{SEP} \d{1,5} /xo
  AREA  = / \d{2,6} | \(\d{2,6}\) /xo
  LINE  = / \d{2,4} #{SEP} \d{4} /xo
  EXT   = /#{SEP}(ext|x)#{SEP}\d{1,5}/xo
  PHONE = /\A ((#{WORLD}|#{AREA}) #{SEP} #{LINE} #{EXT}?)? \Z/xo

  validates_presence_of :name, :message => "Please enter your name."
  validates_presence_of :address
  validates_format_of   :telephone, :with => PHONE,
                        :message => "Does not look like a phone number."
  validates_format_of   :fax, :with => PHONE,
                        :message => "Does not look like a phone number."

  has_many :studies

  private  
  def map_openid_registration(registration)
    self.name = registration["fullname"] if name.blank?
    self.email = registration["email"] if email.blank?  
    self.username = registration["nickname"] if username.blank?  
  end  
end
