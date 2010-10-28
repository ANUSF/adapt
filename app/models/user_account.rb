class UserAccount < ActiveRecord::Base
  devise :openid_authenticatable

  def self.create_from_identity_url(identity_url)
    UserAccount.create(:identity_url => identity_url)
  end
end
