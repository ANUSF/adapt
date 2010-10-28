class DeviseCreateUserAccounts < ActiveRecord::Migration
  def self.up
    create_table(:user_accounts) do |t|
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable

      # t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable


      t.timestamps
    end

    add_index :user_accounts, :email,                :unique => true
    add_index :user_accounts, :reset_password_token, :unique => true
    # add_index :user_accounts, :confirmation_token,   :unique => true
    # add_index :user_accounts, :unlock_token,         :unique => true
  end

  def self.down
    drop_table :user_accounts
  end
end
