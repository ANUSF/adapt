class StudiesDecodeColumns < ActiveRecord::Migration
  include ActiveSupport

  def self.up
    for study in Study.all
      study.data_kind          = JSON::decode(study.data_kind || "[]")
      study.time_method        = JSON::decode(study.time_method || "[]")
      study.sampling_procedure = JSON::decode(study.sampling_procedure || "[]")
      study.collection_mode    = JSON::decode(study.collection_mode || "[]")
      study.save!
    end
  end

  def self.down
    for study in Study.all
      study.data_kind          = study.data_kind.to_json
      study.time_method        = study.time_method.to_json
      study.sampling_procedure = study.sampling_procedure.to_json
      study.collection_mode    = study.collection_mode.to_json
      study.save!
    end
  end
end
