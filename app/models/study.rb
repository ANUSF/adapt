class Study < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :title

  attr_accessible (:name, :title, :abstract, :data_kind, :time_method,
                   :sample_population, :sampling_procedure, :collection_mode,
                   :collection_start, :collection_end, :period_start,
                   :period_end, :loss_prevention, :depositors,
                   :principal_investigators, :data_collectors,
                   :research_initiators, :funding_agency,
                   :other_acknowledgements)

  def label_for(column)
    case column.to_sym
    when :name			then "Short name"
    when :title			then "Study title"
    when :abstract		then "Study abstract"
    when :data_kind		then "Kind of data"
    when :time_method		then "Time dimensions"
    when :sample_population	then "Sample population"
    when :sampling_procedure	then "Sampling procedures"
    when :collection_mode	then "Method of data collection"
    when :collection_start	then "Start date of data collection"
    when :collection_end	then "End date of data collection"
    when :period_start		then "Start date of period data refers to"
    when :period_end		then "End date of period data refers to"
    when :loss_prevention	then "Actions to minimise loss"
    when :depositors		then "Depositor"
    when :principal_investigators then "Principal investigator(s)"
    when :data_collectors	then "Data collector(s)"
    when :research_initiators	then "Research initiator(s)"
    when :funding_agency	then "Funding agency"
    end
  end

  def help_on(column)
    case column.to_sym
    when :name			then "Short name to use for later reference."
    when :title			then "The full title of this study."
    when :abstract		then "The study abstract."
    when :data_kind		then
      "Please indicate the kind of data collected (e.g. survey; census data; \
textual data; clinical data; process-produced data; psychological tests)"
    when :time_method		then "Time dimensions"
    when :sample_population	then
      "Please desscribe the universe that was being sampled in this study. \
Specify any limitations on age, sex, location, occupation, etc. of the \
population"
    when :sampling_procedure	then "Sampling procedures"
    when :collection_mode	then "Method of data collection"
    when :collection_start	then "Start date of data collection"
    when :collection_end	then "End date of data collection"
    when :period_start		then
      "If the data pertains to a period prior to the time when it was \
collected (e.g. medical records for 1980-1990 collected in 1992) what period \
does the data come from? "
    when :period_end		then
      "If the data pertains to a period prior to the time when it was \
collected (e.g. medical records for 1980-1990 collected in 1992) what period \
does the data come from? "
    when :loss_prevention	then
      "Provide details of any actions that were taken to increase the \
response rate (e.g. follow-up letters, financial inducements, call-backs)"
    when :depositors		then
      "Please give details of person(s) sending the materials"
    when :principal_investigators then
      "Please list the name(s) of each principal investigator and the \
organisation with which they are associated"
    when :data_collectors	then
      "List if different from the principal investigator(s)"
    when :research_initiators	then
      "If the study was conducted for a particular person or organisation, \
please list them"
    when :funding_agency	then
      "Please list then names(s) of all funding source(s) (include the grant \
number if appropriate)"
    when :other_acknowledgements then
      "Please list the names of any other persons or organisations who played a significant role in the conduct of the study"
    end
  end
end
