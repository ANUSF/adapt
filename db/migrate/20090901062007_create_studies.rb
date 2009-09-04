class CreateStudies < ActiveRecord::Migration
  def self.up
    create_table :studies do |t|
      t.integer :user_id
      t.string :permanent_identifier
      t.string :name
      t.string :status
      t.text :ddi
      t.timestamps
    end
  end
  
  def self.down
    drop_table :studies
  end
end
