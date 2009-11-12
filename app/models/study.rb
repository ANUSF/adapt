class Study < ActiveRecord::Base
  belongs_to :user
  has_many :attachments, :dependent => :destroy

  JSON_FIELDS = [:data_is_qualitative, :data_is_quantitative, :data_kind,
                 :time_method, :sample_population,
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

  def self.property_accessor(name)
    define_method(name) do |column|
      props = @@field_properties[column.to_sym] || {}
      res = props[name.to_sym] || @@field_properties[:__defaults__][name.to_sym]
      res.class == Proc ? res.call(column) : res
    end
  end

  for name in %w{label_for help_on selections subfields is_repeatable?}
    property_accessor(name)
  end

  protected

  @@field_properties = {
    :__defaults__ => {
      :label_for => proc { |column| column.to_s.humanize },
      :help_on => proc { |column| column.to_s.humanize },
      :selections => [],
      :subfields => [],
      :is_repeatable? => false
    },
    :name => {
      :label_for => "Short name",
      :help_on => "Short name to use for later reference."
    },
    :title => {
      :label_for => "Study title",
      :help_on => "The full title of this study."
    },
    :abstract => {
      :label_for => "Study abstract",
      :help_on => "The study abstract."
    },
    :data_is_qualitative=> {
      :label_for => "Qualitative Data"
    },
    :data_is_quantitative=> {
      :label_for => "Quantitative Data"
    },
    :data_kind => {
      :label_for => "Kind of data",
      :is_repeatable? => true,
      :selections => [
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
      :label_for => "Time dimensions",
      :is_repeatable? => true,
      :selections => ["one-time cross-sectional study",
                      "follow-up cross-sectional study",
                      "repeated cross-sectional study",
                      "longitudinal/panel/cohort study",
                      "time series",
                      "trend study"]
      },
    :sample_population => {
      :label_for => "Sample population",
      :help_on =>
"Please describe the universe that was being sampled in this study. \
Specify any limitations on age, sex, location, occupation, etc. of the \
population."
      },
    :sampling_procedure => {
      :label_for => "Sampling procedures",
      :is_repeatable? => true,
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
      :label_for => "Method of data collection",
      :is_repeatable? => true,
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
      :label_for => ""
    },
    :collection_end => {
      :label_for => ""
    },
    :period_start => {
      :label_for => "",
      :help_on => 
"If the data pertains to a period prior to the time when it was \
collected (e.g. medical records for 1980-1990 collected in 1992) what \
period does the data come from? "
    },
    :period_end => {
      :label_for => "",
      :help_on =>
"If the data pertains to a period prior to the time when it was \
collected (e.g. medical records for 1980-1990 collected in 1992) what \
period does the data come from? "
      },
    :response_rate => {
    },
    :depositors => {
      :subfields => %w{name affiliation},
      :label_for => "Depositor:",
      :help_on => "Please give details of the person sending the materials."
    },
    :principal_investigators => {
      :subfields => %w{name affiliation},
      :is_repeatable? => true,
      :label_for => "Principal Investigator(s):",
      :help_on =>
"Please list the name(s) of each principal investigator and the \
organisation with which they are associated. Click 'Refresh' for \
additional lines."
    },
    :data_producers => {
      :subfields => %w{name affiliation},
      :is_repeatable? => true,
      :label_for => "Data Producer(s):",
      :help_on =>
"List if different from the principal investigator(s). Click 'Refresh' \
for additional lines."
    },
    :funding_agency => {
      :subfields => %w{agency grant_number},
      :is_repeatable? => true,
      :label_for => "Funding:",
      :help_on =>
"Please list then names(s) of all funding source(s) (include the grant \
number if appropriate). Click 'Refresh' for additional lines."
    },
    :other_acknowledgements => {
      :subfields => %w{name affiliation role},
      :is_repeatable? => true,
      :label_for => "Other Acknowledgements:",
      :help_on =>
"Please list the names of any other persons or organisations who \
played a significant role in the conduct of the study. Click 'Refresh' \
for additional lines."
    }
  }
end
