class StudiesAddAcknowledgements < ActiveRecord::Migration
  def self.up
    change_table :studies do |t|
      t.text :depositors		# DDI: depositr
      t.text :principal_investigators	# DDI: ???
      t.text :data_collectors		# DDI: ???
      t.text :research_initiators	# DDI: ???
      t.text :funding_agency		# DDI: ???
      t.text :other_acknowledgements	# DDI: ???
    end
  end

  def self.down
    change_table :studies do |t|
      t.remove :depositors
      t.remove :principal_investigators
      t.remove :data_collectors
      t.remove :research_initiators
      t.remove :funding_agency
      t.remove :other_acknowledgements
    end
  end
end
