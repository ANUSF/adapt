class Study < ActiveRecord::Base
  include ModelSupport

  belongs_to :owner,     :class_name => 'User', :foreign_key => :user_id
  belongs_to :archivist, :class_name => 'User', :foreign_key => :archivist_id
  belongs_to :manager,   :class_name => 'User', :foreign_key => :manager_id
  has_many   :attachments, :dependent => :destroy
  has_one    :licence ,    :dependent => :destroy
  accepts_nested_attributes_for :licence
  accepts_nested_attributes_for :attachments, :allow_destroy => true

  JSON_FIELDS = [:data_is_qualitative, :data_is_quantitative, :data_kind,
                 :time_method, :sample_population,
                 :sampling_procedure, :collection_method, :collection_start,
                 :collection_end, :period_start, :period_end, :response_rate,
                 :depositors, :principal_investigators, :data_producers,
                 :funding_agency, :other_acknowledgements, :references]

  attr_accessible(*(JSON_FIELDS +
                    [:name, :title, :abstract, :new_upload,
                     :attachments_attributes, :licence_attributes,
                     :additional_metadata]))

  validates_presence_of :title, :message => 'May not be blank.'
  validates_uniqueness_of :title, :scope => :user_id,
                          :case_sensitive => false,
                          :message => 'You have another study with this title.'
  validates_presence_of :abstract, :message => 'May not be blank.'

  validates_each :attachments, :if => :checking do |rec, attr, val|
    if val.select { |a| a.category == "Data File" }.empty?
      rec.errors.add attr, 'Please supply at least one data file.'
    end
  end

  validates_each :data_is_quantitative, :if => :checking do |rec, attr, val|
    if val == "0" and rec.data_is_qualitative == "0"
      rec.errors.add 'Data Category', 'Please select at least one.'
    end
  end

  validates_presence_of :data_kind, :if => :checking,
                        :message => 'Please specify at least one.'

  validates_each :collection_start, :collection_end,
                 :period_start, :period_end, :if => :checking do |rec, attr, val|
    range, part = attr.to_s.split("_")
    if (not val.blank?) and (date = rec.parse_and_validate_date(range, val))
      rec.send(attr.to_s + "=", date.pretty)
      opp = (range + (part == "start" ? "_end" : "_start")).to_sym
      rec.send("#{opp}=", date.pretty) if rec.send(opp).blank?
      if part == "end"
        begin_date = rec.parse_and_validate_date(:dummy, rec.send(opp))
        if begin_date and date.before?(begin_date)
          rec.errors.add range, "End date must not be before begin date."
        end
      end
    end
  end

  validates_each :depositors, :if => :checking do |rec, attr, val|
    if val.nil? or (val['affiliation'].blank? and val['name'].blank?)
      rec.errors.add attr, 'May not be blank.'
    elsif val['affiliation'].blank? or val['name'].blank?
      rec.errors.add attr, 'Please provide both a name and an affiliation.'
    end
  end

  validates_each :principal_investigators, :if => :checking do |rec, attr, val|
    if val.blank?
      rec.errors.add attr, 'Please list at least one.'
    elsif val.any? { |pi| pi['name'].blank? or pi['affiliation'].blank? }
      rec.errors.add attr, 'Please provide both names and affiliations.'
    end
  end

  accesses_via_json :additional_metadata

  attr_reader :checking

  json_fields(*JSON_FIELDS)

  def new_upload=(params)
    content = params[:content]
    if content.original_filename.ends_with? '.zip'
      each_zip_entry(content.read) do |name, data|
        attachments << Attachment.make(File.basename(name), data)
      end
    else
      attachments.create(params)
    end
  end

  def status
    result = read_attribute('status')
    if result.blank? or %w{incomplete unsubmitted}.include? result
      if ready_for_submission?
        "unsubmitted"
      else
        "incomplete"
      end
    else
      result
    end
  end

  include UniqueDirectory

  def submit(licence, ddi)
    def write_file(dir, filename, data)
      File.open(File.join(dir, filename), "w", 0640) { |fp| fp.write(data) }
    end

    base_path = File.join(ENV['ADAPT_ASSET_PATH'], "Submission")
    identifier = next_unique_directory_name(base_path, "TMP")
    path = File.join(base_path, identifier)

    data_path = File.join(path, "DataFiles")
    doc_path = File.join(path, "Documentation")
    FileUtils.mkdir_p(data_path, :mode => 0755)
    FileUtils.mkdir_p(doc_path, :mode => 0755)

    write_file(path, "Licence.txt", licence)
    write_file(path, "Study.ddi", ddi)
    write_file(path, "FileDescriptions.txt",
               attachments.map { |a| a.metadata.to_yaml }.join("\n"))
    attachments.each { |a|
      dir = (a.category == "Documentation") ? doc_path : data_path
      write_file(dir, a.name, a.data)
    }

    update_attribute(:status, "submitted")
    update_attribute(:permanent_identifier, identifier)
    UserMailer.deliver_submission_notification(self)
  end

  def approve(assigned_archivist)
    self.status = "approved"
    self.archivist = assigned_archivist
    save
  end

  def reopen
    update_attribute(:status, "unsubmitted")
  end

  def can_be_viewed_by(person)
    case person && person.role
    when 'contributor' then person == owner
    when 'archivist'   then true
    when 'admin'       then true
    else                    false
    end
  end

  def can_be_edited_by(person)
    case person && person.role
    when 'contributor' then person == owner and
                            %w{incomplete unsubmitted}.include? status
    when 'archivist'   then person == archivist
    else                    false
    end
  end

  def can_be_submitted_by(person)
    person == owner
  end
  
  def can_be_approved_by(person)
    (person && person.role) == 'admin' and (manager == person or manager.nil?)
  end
  
  def ready_for_submission?
    @checking = true
    study_ready = valid?
    @checking = false
    licence_ready = licence && licence.ready_for_submission?
    attachments_ready = attachments.map(&:ready_for_submission?).all?

    study_ready and licence_ready and attachments_ready
  end

  protected

  def self.annotate_with(name)
    define_method(name) do |column|
      props = @@field_annotations[column.to_sym] || {}
      key = name.to_sym
      res = props[key] || @@field_annotations[:__defaults__][key]
      res.class == Proc ? res.call(self, column) : res
    end
  end

  for name in %w{label_for help_on selections subfields is_repeatable?
                 allow_other?}
    annotate_with(name)
  end

  @@field_annotations = {
    :__defaults__ => {
      :label_for => proc { |object, column| column.to_s.humanize },
      :help_on => proc { |object, column| object.label_for(column) },
      :selections => [],
      :subfields => [],
      :is_repeatable? => false,
      :allow_other? => false
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
    :archivist => {
      :label_for => "",
      :help_on => "Select the archivist to curate this submission.",
      :selections => proc { User.archivists.map { |a| [a.name, a.id] } } 
    },
    :data_is_qualitative=> {
      :label_for => "Qualitative"
    },
    :data_is_quantitative=> {
      :label_for => "Quantitative"
    },
    :data_kind => {
      :label_for => "Kind of data",
      :is_repeatable? => true,
      :allow_other? => true,
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
      :allow_other? => true,
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
      :allow_other? => true,
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
      :allow_other? => true,
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
      :label_for => "Response rate:"
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
    },
    :references => {
      :subfields => ["title", "author", "details"],
      :is_repeatable? => true,
      :help_on =>
"Please provide the bibliographic details and, where available, online \
links to any published work (including journal articles, books or book \
chapters, conference presentations, theses or any other publications \
or outputs) based wholly or in part on the material."
    }
  }
end
