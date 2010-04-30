class Study < ActiveRecord::Base
  include ModelSupport
  include UniqueFileNaming

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

  def identifier
    permanent_identifier || temporary_identifier
  end

  def long_identifier
    "au.edu.assda.ddi.#{identifier || "xxxxx"}"
  end

  def ddi
    av = ActionView::Base.new(Rails::Configuration.new.view_path)
    class << av
      include StudiesHelper
    end
    av.assigns[:study] = self
    av.render "studies/ddi.xml"
  end

  def submit(licence_text)
    identifier = next_unique_directory_name(submission_path, "deposit_")

    self.temporary_identifier = identifier.sub(/_/, ':')
    self.status = "submitted"
    save

    base = File.join(submission_path, identifier)
    write_file(licence_text, base, "Licence.txt")
    write_file(ddi, base, "Study.xml")
    write_file(attachments.map { |a| a.metadata.to_yaml }.join("\n"),
               base, "FileDescriptions.txt")
    attachments.each do |a|
      write_file(a.data, base, a.category.gsub(/\s/, '').pluralize, a.name)
    end

    UserMailer.deliver_submission_notification(self)
  end

  def approve(assigned_archivist, range = "0")
    licence_text = read_file(submission_path,
                             temporary_identifier.sub(/:/, '_'),
                             "Licence.txt")

    self.permanent_identifier ||=
      next_unique_directory_name(archive_path, range, 5 - range.size)
    self.status = "approved"
    self.archivist = assigned_archivist
    save

    base = non_conflicting(File.join(archive_path,
                                     self.permanent_identifier, "Original"))
    write_file(licence_text, base, "ASSDA.Deposit.Licence.#{identifier}.txt")
    write_file(ddi, base, "#{long_identifier}.xml")

    filedata = []
    attachments.each do |a|
      name = "#{long_identifier}#{File.extname(a.name)}"
      path = non_conflicting(File.join(base, name))
      filedata << a.metadata.merge("Filename" => File.basename(path),
                                   "Original" => a.name).to_yaml
      write_file(a.data, path)
    end
    write_file(filedata.join("\n"), base, "Processing", "FileDescriptions.txt")

    UserMailer.deliver_archivist_assignment(self)
  end

  def reopen
    self.status = "unsubmitted"
    save
  end

  protected

  def submission_path
    base_path = File.join(ENV['ADAPT_ASSET_PATH'], "Submission")
  end

  def archive_path
    base_path = File.join(ENV['ADAPT_ASSET_PATH'], "Archive")
  end

  def write_file(data, *path_parts)
    path = File.join(*path_parts)
    FileUtils.mkpath(File.dirname(path), :mode => 0755)
    File.open(non_conflicting(path), "w", 0640) { |fp| fp.write(data) }
  end

  def read_file(*path_parts)
    File.open(File.join(*path_parts)) { |fp| fp.read }
  end

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
