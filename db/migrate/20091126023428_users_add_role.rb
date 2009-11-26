class UsersAddRole < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :role
    end
    for user in User.all
      user.role = "contributor"
      user.save!
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :role
    end
  end
end
