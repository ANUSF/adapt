class MigrateOpenids < ActiveRecord::Migration
  def self.up
    for user in Adapt::User.all
      oid = user.openid_identifier
      oid = oid.sub(/wyrd.anu.edu.au:8080/, "openid.assda.edu.au")
      user.update_attribute(:openid_identifier, oid)
    end
  end

  def self.down
    for user in Adapt::User.all
      oid = user.openid_identifier
      oid = oid.sub(/openid.assda.edu.au/, "wyrd.anu.edu.au:8080")
      user.update_attribute(:openid_identifier, oid)
    end
  end
end
