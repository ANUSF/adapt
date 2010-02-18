class CreateLicences < ActiveRecord::Migration
  def self.up
    create_table :licences do |t|
      t.integer :study_id
      t.string :access_mode
      t.string :signed_by
      t.string :email
      t.string :signed_date

      t.timestamps
    end
  end

  def self.down
    drop_table :licences
  end
end
