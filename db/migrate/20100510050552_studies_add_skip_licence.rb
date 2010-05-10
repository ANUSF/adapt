class StudiesAddSkipLicence < ActiveRecord::Migration
  def self.up
    change_table :studies do |t|
      t.boolean :skip_licence
    end
  end

  def self.down
    change_table :studies do |t|
      t.remove :skip_licence
    end
  end
end
