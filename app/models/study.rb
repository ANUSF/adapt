class Study < ActiveRecord::Base
  extend Accessors

  belongs_to :user

  attr_accessible(:name, :title, :abstract, :data_kind, :time_method,
                  :sample_population, :sampling_procedure, :collection_mode,
                  :collection_start, :collection_end, :period_start,
                  :period_end, :loss_prevention, :depositors,
                  :principal_investigators, :data_collectors,
                  :research_initiators, :funding_agency,
                  :other_acknowledgements, :additional_metadata)

  validates_presence_of :title
  validates_presence_of :abstract

  json_accessors :data_kind
  json_accessors :time_method
  json_accessors :sample_population
  json_accessors :sampling_procedure
  json_accessors :collection_mode
  json_accessors :collection_start
  json_accessors :collection_end
  json_accessors :period_start
  json_accessors :period_end
  json_accessors :loss_prevention
  json_accessors :depositors
  json_accessors :principal_investigators
  json_accessors :data_collectors
  json_accessors :research_initiators
  json_accessors :funding_agency
  json_accessors :other_acknowledgements

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
    when :collection_mode
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
    when :loss_prevention
      {
        :label => "Actions to minimise loss",
        :help =>
"Provide details of any actions that were taken to increase the \
response rate (e.g. follow-up letters, financial inducements, \
call-backs)"
      }
    when :depositors
      {
        :label => "Depositor",
        :help => "Please give details of person(s) sending the materials"
      }
    when :principal_investigators
      {
        :help =>
"Please list the name(s) of each principal investigator and the \
organisation with which they are associated"
      }
    when :data_collectors
      {
        :help => "List if different from the principal investigator(s)"
      }
    when :research_initiators
      {
        :help =>
"If the study was conducted for a particular person or organisation, \
please list them"
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
