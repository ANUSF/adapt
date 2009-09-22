class Study < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :title

  attr_accessible(:name, :title, :abstract, :data_kind, :time_method,
                  :sample_population, :sampling_procedure, :collection_mode,
                  :collection_start, :collection_end, :period_start,
                  :period_end, :loss_prevention, :depositors,
                  :principal_investigators, :data_collectors,
                  :research_initiators, :funding_agency,
                  :other_acknowledgements)

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
        :help =>
"Please indicate the kind of data collected (e.g. survey; census data; \
textual data; clinical data; process-produced data; psychological \
tests)"
      }
    when :time_method
      {
        :label => "Time dimensions",
        :selections => ["one-time cross-sectional study",
                        "follow-up cross-sectional study",
                        "repeated cross-sectional study",
                        "longitudinal/panel/cohort study",
                        "time series", "trend study", "other"]
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
        :label => "Sampling procedures"
      }
    when :collection_mode
      {
        :label => "Method of data collection"
      }
    when :collection_start
      {
        :label => "Start date of data collection"
      }
    when :collection_end
      {
        :label => "End date of data collection"
      }
    when :period_start
      {
        :label => "Start date of period data refers to",
        :help => 
"If the data pertains to a period prior to the time when it was \
collected (e.g. medical records for 1980-1990 collected in 1992) what \
period does the data come from? "
      }
    when :period_end
      {
        :label => "End date of period data refers to",
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
