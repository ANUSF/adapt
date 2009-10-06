class OverwriteStudies < ActiveRecord::Migration
  class Relic < ActiveRecord::Base
  end

  class Study < ActiveRecord::Base
  end

  def self.up
    drop_table   :studies
    rename_table :clones, :studies
  end

  def self.down
    create_table :relics do |t|
      t.integer  :user_id
      t.string   :permanent_identifier
      t.string   :name
      t.string   :status
      t.text     :ddi
      t.timestamps
      t.text     :title
      t.text     :abstract
      t.string   :data_kind
      t.string   :time_method
      t.text     :sample_population
      t.string   :sampling_procedure
      t.string   :collection_mode
      t.datetime :collection_start
      t.datetime :collection_end
      t.datetime :period_start
      t.datetime :period_end
      t.text     :loss_prevention
      t.text     :depositors
      t.text     :principal_investigators
      t.text     :data_collectors
      t.text     :research_initiators
      t.text     :funding_agency
      t.text     :other_acknowledgements
    end

    for study in Study.all
      attr = {
        :user_id                 => study.user_id,
        :permanent_identifier    => study.permanent_identifier,
        :name                    => study.name,
        :status                  => study.status,
        :title                   => study.title,
        :abstract                => study.abstract,
        :created_at              => study.created_at,
        :updated_at              => study.updated_at
      }
      meta = ActiveSupport::JSON::decode(study.additional_metadata)
      Relic.new(attr.merge(meta)).save!
    end

    rename_table :studies, :clones
    rename_table :relics, :studies
  end
end
