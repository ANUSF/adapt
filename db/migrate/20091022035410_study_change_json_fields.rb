class StudyChangeJsonFields < ActiveRecord::Migration
  def self.up
    for study in Adapt::Study.all
      fields = study.read_json
      fields["data_producers"] = (fields["data_collectors"] || []) +
        (fields["research_initiators"] || [])
      fields["response_rate"] = fields["loss_prevention"]
      fields["collection_method"] = fields["collection_mode"]

      for name in %w{data_collectors research_initiators loss_prevention
                     collection_mode}
        fields.delete(name)
      end

      study.write_json(fields)
      study.save!
    end
  end

  def self.down
    for study in Adapt::Study.all
      fields = study.read_json
      fields["data_collectors"] = fields["data_producers"]
      fields["research_initiators"] = []
      fields["loss_prevention"] = fields["response_rate"]
      fields["collection_mode"] = fields["collection_method"]

      for name in %w{data_producers response_rate collection_method}
        fields.delete(name)
      end

      study.write_json(fields)
      study.save!
    end
  end
end
