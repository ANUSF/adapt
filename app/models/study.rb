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

  def subfields(column)
    Study.field_properties(column)[:subfields] || []
  end

  def is_repeatable?(column)
    Study.field_properties(column)[:repeatable] || false
  end

  protected

  def self.field_properties(column)
    @@field_properties[column.to_sym] or {}
  end

  @@field_properties = {
    :name => {
      :label => "Short name",
      :help => "Short name to use for later reference."
    },
    :title => {
      :label => "Study title",
      :help => "The full title of this study."
    },
    :abstract => {
      :label => "Study abstract",
      :help => "The study abstract."
    },
    :data_kind => {
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
      },
    :time_method => {
      :label => "Time dimensions",
      :selections => ["one-time cross-sectional study",
                      "follow-up cross-sectional study",
                      "repeated cross-sectional study",
                      "longitudinal/panel/cohort study",
                      "time series",
                      "trend study"]
      },
    :sample_population => {
      :label => "Sample population",
      :help =>
"Please desscribe the universe that was being sampled in this study. \
Specify any limitations on age, sex, location, occupation, etc. of the \
population"
      },
    :sampling_procedure => {
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
      },
    :collection_method => {
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
    },
    :collection_start => {
      :label => ""
    },
    :collection_end => {
      :label => ""
    },
    :period_start => {
      :label => "",
      :help => 
"If the data pertains to a period prior to the time when it was \
collected (e.g. medical records for 1980-1990 collected in 1992) what \
period does the data come from? "
    },
    :period_end => {
      :label => "",
      :help =>
"If the data pertains to a period prior to the time when it was \
collected (e.g. medical records for 1980-1990 collected in 1992) what \
period does the data come from? "
      },
    :response_rate => {
    },
    :depositors => {
      :subfields => %w{name affiliation},
      :label => "Depositor:",
      :help => "Please give details of person(s) sending the materials"
    },
    :principal_investigators => {
      :subfields => %w{name affiliation},
      :label => "Principal Investigator(s):",
      :help =>
"Please list the name(s) of each principal investigator and the \
organisation with which they are associated"
    },
    :data_producers => {
      :subfields => %w{name affiliation},
      :repeatable => true,
      :label => "Data Producer(s):",
      :help => "List if different from the principal investigator(s)"
    },
    :funding_agency => {
      :subfields => %w{agency grant_number},
      :label => "Funding:",
      :help =>
"Please list then names(s) of all funding source(s) (include the grant \
number if appropriate)"
    },
    :other_acknowledgements => {
      :subfields => %w{name affiliation role},
      :label => "Other Acknowledgements:",
      :help =>
"Please list the names of any other persons or organisations who \
played a significant role in the conduct of the study"
    }
  }
end
