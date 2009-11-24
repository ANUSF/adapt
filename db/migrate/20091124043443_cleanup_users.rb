# Since the jdbc adapter for sqlite3 does not support changing and removing
# columns, we use an intermediate table 'clones'.

class CleanupUsers < ActiveRecord::Migration
  class Clone < ActiveRecord::Base
  end

  def self.up
    create_table :clones do |t|
      t.string   :openid_identifier
      t.string   :username
      t.string   :email
      t.string   :name
      t.text     :address
      t.string   :telephone
      t.string   :fax
      t.datetime :created_at
      t.datetime :updated_at
    end
    
    User.all.each do |user|
      attributes = user.attributes.reject do |k, v|
        %w{crypted_password password_salt persistence_token}.include? k
      end
      clone = Clone.create!(attributes)
      user.studies.each do |study|
        study.user_id = clone.id
        study.save!
      end
    end

    drop_table :users
    rename_table :clones, :users
  end

  def self.down
    change_table :users do |t|
      t.string   :crypted_password
      t.string   :password_salt
      t.string   :persistence_token
    end
  end
end
