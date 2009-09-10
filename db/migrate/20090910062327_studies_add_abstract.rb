class StudiesAddAbstract < ActiveRecord::Migration
  def self.up
    change_table :studies do |t|
      t.text :abstract
    end
  end

  def self.down
    change_table :studies do |t|
      t.remove :abstract
    end
  end
end
