class StudiesAddTemporaryIdentifier < ActiveRecord::Migration
  def self.up
    change_table :studies do |t|
      t.string :temporary_identifier
    end
  end

  def self.down
    change_table :studies do |t|
      t.remove :temporary_identifier
    end
  end
end
