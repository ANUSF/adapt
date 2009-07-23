class CreateSubmissions < ActiveRecord::Migration
  def self.up
    create_table :submissions do |t|
      t.integer :user_id
      t.string :study_identifier
      t.string :name
      t.timestamps
    end
  end
  
  def self.down
    drop_table :submissions
  end
end
