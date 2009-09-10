class StudiesAddTitle < ActiveRecord::Migration
  def self.up
    change_table :studies do |t|
      t.text :title
    end
  end

  def self.down
    change_table :studies do |t|
      t.remove :title
    end
  end
end
