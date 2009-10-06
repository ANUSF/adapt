# Since the jdbc adapter for sqlite3 does not support changing and removing
# columns, we use two separate migration to first copy the data from the
# studies table into a new table and then replace the old table with the new
# one. The two-step process makes sure no data is lost if the conversion
# fails in either the "up" or "down" direction.

class CloneStudies < ActiveRecord::Migration
  class Study < ActiveRecord::Base
  end

  class Clone < ActiveRecord::Base
  end

  def self.up
    create_table :clones do |t|
      t.integer :user_id
      t.string  :permanent_identifier
      t.string  :name
      t.string  :status
      t.text    :title
      t.text    :abstract
      t.text    :additional_metadata
      t.timestamps
    end

    for study in Study.all
      meta = {
        :data_kind               => study.data_kind,
        :time_method             => study.time_method,
        :sample_population       => study.sample_population,
        :sampling_procedure      => study.sampling_procedure,
        :collection_mode         => study.collection_mode,
        :collection_start        => study.collection_start,
        :collection_end          => study.collection_end,
        :period_start            => study.period_start,
        :period_end              => study.period_end,
        :loss_prevention         => study.loss_prevention,
        :depositors              => study.depositors,
        :principal_investigators => study.principal_investigators,
        :data_collectors         => study.data_collectors,
        :research_initiators     => study.research_initiators,
        :funding_agency          => study.funding_agency,
        :other_acknowledgements  => study.other_acknowledgements
      }
      c = Clone.new(:user_id              => study.user_id,
                    :permanent_identifier => study.permanent_identifier,
                    :name                 => study.name,
                    :status               => study.status,
                    :title                => study.title,
                    :abstract             => study.abstract,
                    :created_at           => study.created_at,
                    :updated_at           => study.updated_at,
                    :additional_metadata  => meta.to_json)
      c.save!
    end
  end

  def self.down
    drop_table :clones
  end
end
