class Study < ActiveRecord::Base
  belongs_to :user

  JSON_FIELDS = [:data_kind, :time_method, :sample_population,
                 :sampling_procedure, :collection_method, :collection_start,
                 :collection_end, :period_start, :period_end, :response_rate,
                 :depositors, :principal_investigators, :data_producers,
                 :funding_agency, :other_acknowledgements]

  attr_accessible(*([:name, :title, :abstract, :additional_metadata] +
                    JSON_FIELDS))

  validates_presence_of :title
  validates_presence_of :abstract

  accesses_via_json :additional_metadata

  json_fields(*JSON_FIELDS)

  def label_for(column)
    Study.field_properties(column)[:label] || column.to_s.humanize
  end

  def help_on(column)
    Study.field_properties(column)[:help] || label_for(column)
  end

  def selections(column)
    Study.field_properties(column)[:selections] || []
  end

  protected

  def self.field_properties(column)
    case column.to_sym
    when :name
      {
        :label => "Short name",
        :help => "Short name to use for later reference."
      }
    when :title
      {
        :label => "Study title",
        :help => "The full title of this study."
      }
    when :abstract
      {
        :label => "Study abstract",
        :help => "The study abstract."
      }
    when :data_kind
      {
        :label => "Kind of data",
        :selections => [
                        "Qualitative",
                        "Quantitative",
                        "Administrative / process-produced data",
                        "Audio-taped interviews",
                        "Case study notes",
                        "Census data",
                        "Clinical data",
                        "Coded documents ",
                        "Correspondence",
                        "Educational test data",
                        "Election returns",
                        "Experimental data",
                        "Field notes",
                        "Focus group transcripts",
                        "Image",
                        "Interview notes",
                        "Interview summaries or extracts",
                        "Interview transcripts",
                        "Kinship diagrams",
                        "Minutes of meetings",
                        "Naturally occurring speech/conversation transcripts",
                        "Observational ratings/data",
                        "Photographs",
                        "Press clippings",
                        "Publications",
                        "Psychological test",
                        "Sound",
                        "Statistics/aggregate data",
                        "Survey data",
                        "Textual data",
                        "Time budget diaries/data",
                        "Video-taped interviews" ]
      }
    when :time_method
      {
        :label => "Time dimensions",
        :selections => ["one-time cross-sectional study",
                        "follow-up cross-sectional study",
                        "repeated cross-sectional study",
                        "longitudinal/panel/cohort study",
                        "time series",
                        "trend study"]
      }
    when :sample_population
      {
        :label => "Sample population",
        :help =>
"Please desscribe the universe that was being sampled in this study. \
Specify any limitations on age, sex, location, occupation, etc. of the \
population"
      }
    when :sampling_procedure
      {
        :label => "Sampling procedures",
        :selections => ["no sampling (total universe)",
                        "simple random sample",
                        "one-stage stratified or systematic random sample",
                        "multi-stage sample",
                        "multi-stage stratified random sample",
                        "one-stage cluster sample",
                        "area-cluster sample",
                        "quota sample",
                        "quasi-random (e.g. random walk) sample",
                        "purposive selection/case studies",
                        "volunteer sample",
                        "convenience sample"]
      }
    when :collection_method
      {
        :label => "Method of data collection",
        :selections => ["clinical measurements",
                        "compilation or synthesis of existing material",
                        "diaries",
                        "educational measurements",
                        "email survey",
                        "face-to-face interview",
                        "observation",
                        "physical measurements",
                        "postal survey",
                        "psychological measurements",
                        "self-completion",
                        "simulation",
                        "telephone interview",
                        "transcription of existing materials",
                        "web-based self-completion"]
      }
    when :collection_start
      {
        :label => ""
      }
    when :collection_end
      {
        :label => ""
      }
    when :period_start
      {
        :label => "",
        :help => 
"If the data pertains to a period prior to the time when it was \
collected (e.g. medical records for 1980-1990 collected in 1992) what \
period does the data come from? "
      }
    when :period_end
      {
        :label => "",
        :help =>
"If the data pertains to a period prior to the time when it was \
collected (e.g. medical records for 1980-1990 collected in 1992) what \
period does the data come from? "
      }
    when :response_rate
      {
      }
    when :depositors
      {
        :label => "Depositor",
        :help => "Please give details of person(s) sending the materials"
      }
    when :principal_investigators
      {
        :subfields => %w{Name Affiliation},
        :help =>
"Please list the name(s) of each principal investigator and the \
organisation with which they are associated"
      }
    when :data_producers
      {
        :help => "List if different from the principal investigator(s)"
      }
    when :funding_agency
      {
        :help =>
"Please list then names(s) of all funding source(s) (include the grant \
number if appropriate)"
      }
    when :other_acknowledgements
      {
        :help =>
"Please list the names of any other persons or organisations who \
played a significant role in the conduct of the study"
      }
    end
  end
end
