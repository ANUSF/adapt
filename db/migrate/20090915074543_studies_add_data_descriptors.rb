class StudiesAddDataDescriptors < ActiveRecord::Migration
  def self.up
    change_table :studies do |t|
      t.string   :data_kind		# DDI: dataKind
      t.string   :time_method		# DDI: timeMeth
      t.text     :sample_population	# DDI: ???
      t.string   :sampling_procedure	# DDI: sampProc
      t.string   :collection_mode	# DDI: collMode
      t.datetime :collection_start	# DDI: collDate[event="start"]
      t.datetime :collection_end	# DDI: collDate[event="end"]
      t.datetime :period_start		# DDI: timePrd[event="start"]
      t.datetime :period_end		# DDI: timePrd[event="end"]
      t.text     :loss_prevention	# DDI: ???
    end
  end

  def self.down
      t.remove :data_kind
      t.remove :time_method
      t.remove :sample_population
      t.remove :sampling_procedure
      t.remove :collection_mode
      t.remove :collection_start
      t.remove :collection_end
      t.remove :period_start
      t.remove :period_end
      t.remove :loss_prevention
  end
end
