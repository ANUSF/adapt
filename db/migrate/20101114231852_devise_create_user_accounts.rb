class DeviseCreateUserAccounts < ActiveRecord::Migration
  def self.up
    create_table :user_accounts do |t|
      t.openid_authenticatable
      t.string :name
      t.string :email
    end

    add_index :user_accounts, :identity_url, :unique => true
  end

  def self.down
    drop_table :user_accounts
  end
end
