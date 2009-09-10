class UsersAddNameAddressPhone < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :name
      t.text   :address
      t.string :telephone
      t.string :fax
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :name
      t.remove :address
      t.remove :telephone
      t.remove :fax
    end
  end
end
