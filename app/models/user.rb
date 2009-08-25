class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.transition_from_crypto_providers = Authlogic::CryptoProviders::Sha512
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
  end
  
  has_many :submissions
end
