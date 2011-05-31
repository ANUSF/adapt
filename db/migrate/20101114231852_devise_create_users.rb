class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.openid_authenticatable
      t.string :username
      t.string :name
      t.string :email
      t.string :role
      t.text   :address
      t.string :telephone
      t.string :fax
      t.timestamps
    end

    add_index :users, :identity_url, :unique => true
  end

  def self.down
    drop_table :users
  end
end
