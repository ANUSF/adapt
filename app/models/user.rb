class User < ActiveRecord::Base
  acts_as_authentic do |c|
    crypto_provider = Authlogic::CryptoProviders::BCrypt
  end
end
