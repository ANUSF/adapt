class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.integer :study_id
      t.string :name
      t.string :category
      t.string :format
      t.text :stored_as
      t.text :description
      t.timestamps
    end
  end
  
  def self.down
    drop_table :attachments
  end
end
