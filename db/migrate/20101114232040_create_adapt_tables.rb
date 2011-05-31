class CreateAdaptTables < ActiveRecord::Migration
  def self.up
    create_table :adapt_attachments do |t|
      t.integer  :study_id
      t.string   :name
      t.string   :category
      t.string   :format
      t.text     :stored_as
      t.text     :description
      t.timestamps
    end

    create_table :adapt_licences do |t|
      t.integer  :study_id
      t.string   :access_mode
      t.string   :signed_by
      t.string   :email
      t.string   :signed_date
      t.timestamps
    end

    create_table :adapt_studies do |t|
      t.integer  :user_id
      t.string   :permanent_identifier
      t.string   :status
      t.text     :title
      t.text     :abstract
      t.text     :additional_metadata
      t.integer  :archivist_id
      t.integer  :manager_id
      t.string   :temporary_identifier
      t.boolean  :skip_licence
      t.timestamps
    end
  end

  def self.down
    drop_table :adapt_attachments
    drop_table :adapt_licences
    drop_table :adapt_studies
  end
end
