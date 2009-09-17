class Study < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :title

  attr_accessible (:name, :title, :abstract, :data_kind, :time_method,
                   :sample_population, :sampling_procedure, :collection_mode,
                   :collection_start, :collection_end, :period_start,
                   :period_end, :loss_prevention)

  def help_on(column)
    case column.to_sym
    when :name     then "Short name to use for later reference."
    when :title    then "The full title of this study."
    when :abstract then "The study abstract. Please use only plain text."
    end
  end

  def label_for(column)
    case column.to_sym
    when :name     then "Short Name"
    when :title    then "Study Title"
    when :abstract then "Study Abstract"
    end
  end
end
