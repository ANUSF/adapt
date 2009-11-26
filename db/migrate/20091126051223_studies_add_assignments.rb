class StudiesAddAssignments < ActiveRecord::Migration
  def self.up
    change_table :studies do |t|
      t.integer :archivist_id
      t.integer :manager_id
    end
  end

  def self.down
    change_table :studies do |t|
      t.remove :archivist_id
      t.remove :manager_id
    end
  end
end
