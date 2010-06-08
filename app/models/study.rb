class Study < ActiveRecord::Base
  ID_PREFIX = "au.edu.assda.ddi."

  include ModelSupport
  include FileHandling

  belongs_to :owner,     :class_name => 'User', :foreign_key => :user_id
  belongs_to :archivist, :class_name => 'User', :foreign_key => :archivist_id
  belongs_to :manager,   :class_name => 'User', :foreign_key => :manager_id
  has_many   :attachments, :dependent => :destroy
  has_one    :licence ,    :dependent => :destroy
  accepts_nested_attributes_for :licence
  accepts_nested_attributes_for :attachments, :allow_destroy => true

  before_create { |rec| rec.archivist = rec.owner if rec.owner.is_archivist }

  JSON_FIELDS = [:data_is_qualitative, :data_is_quantitative, :data_kind,
                 :data_relation, :time_method, :sample_population,
                 :sampling_procedure, :collection_method, :collection_start,
                 :collection_end, :period_start, :period_end, :response_rate,
                 :depositors, :principal_investigators, :data_producers,
                 :funding_agency, :other_acknowledgements, :references]

  attr_accessible(*(JSON_FIELDS +
                    [:name, :title, :abstract, :new_upload,
                     :attachments_attributes, :licence_attributes, :skip_licence,
                     :additional_metadata]))

  validates_presence_of :title, :message => 'May not be blank.'
  validates_uniqueness_of :title, :scope => :user_id,
                          :case_sensitive => false,
                          :message => 'You have another study with this title.'
  validates_presence_of :abstract, :if => :checking,
                        :message => 'May not be blank.'

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

  def is_submitted
    %w{submitted approved}.include? status
  end

  def can_be_viewed_by(person)
    person and (person.is_archivist or person == owner)
  end

  def is_listed_for(person)
    person and (person == owner or
                (person.is_archivist and person == archivist) or
                (person.is_admin and is_submitted))
  end

  def can_be_edited_by(person)
    if person and person.is_archivist
      #TODO change this when editing of approved studies works correctly
      person == archivist and not is_submitted
    else
      person == owner and not is_submitted
    end
  end

  def can_be_destroyed_by(person)
    can_be_edited_by(person) and not is_submitted
  end

  def can_be_submitted_by(person)
    person and (person == owner or person == archivist)
  end
  
  def can_be_approved_by(person)
    person and person.is_admin
  end
  
  def ready_for_submission?
    @checking = true
    study_ready = valid?
    @checking = false
    licence_ready = if owner.is_archivist and skip_licence
                      true
                    else
                      licence && licence.ready_for_submission?
                    end
    attachments_ready = attachments.map(&:ready_for_submission?).all?

    study_ready and licence_ready and attachments_ready
  end

  def identifier
    permanent_identifier || temporary_identifier
  end

  def long_identifier
    ID_PREFIX + (identifier || "xxxxx")
  end

  def depositor_name
    depositors and depositors["name"]
  end

  def depositor_affiliation
    depositors and depositors["affiliation"]
  end

  def ddi(with_id = nil)
    av = ActionView::Base.new(Rails::Configuration.new.view_path)
    av.extend StudiesHelper
    av.assigns[:study] = self
    av.assigns[:identifier] = with_id || self.identifier
    av.render "studies/ddi.xml"
  end

  def submit(licence_text)
    ident = next_directory_name(submission_path, "deposit_")
    base = create_directory(submission_path, ident)
    raise 'Folder already exists.' unless base

    self.temporary_identifier = ident.sub(/_/, ':')
    self.status = "submitted"
    save

    write_file(licence_text, base, "Licence.txt") unless licence_text.blank?
    write_file(ddi, base, "Study.xml")
    write_file(attachments.map { |a| a.metadata.to_yaml }.join("\n"),
               base, "FileDescriptions.txt")
    attachments.each do |a|
      write_file(a.data, base, a.category.gsub(/\s/, '').pluralize, a.name)
    end

    UserMailer.deliver_submission_notification(self)
  end

  def approve(assigned_archivist, range = "0")
    if permanent_identifier
      base = File.join(archive_path, permanent_identifier)
    else
      ident = next_directory_name(archive_path, range, 5 - range.size)
      base = create_directory(archive_path, ident)
      raise 'Folder already exists.' unless base
      self.permanent_identifier = ident
    end

    self.status = "approved"
    self.archivist = assigned_archivist
    save

    base = non_conflicting(File.join(base, "Original"))

    licence_text = read_file(submission_path,
                             temporary_identifier.sub(/:/, '_'),
                             "Licence.txt")
    unless licence_text.blank?
      write_file(licence_text, base, "ASSDA.Deposit.Licence.#{identifier}.txt")
    end

    write_file(ddi, base, "#{long_identifier}.xml")

    filedata = []
    attachments.each do |a|
      name = a.name
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
    File.join(ADAPT::CONFIG['adapt.asset.path'], "Submission")
  end

  def archive_path
    File.join(ADAPT::CONFIG['adapt.asset.path'], "Archive")
  end

  def self.transposed(hash)
    result = {}
    hash.each do |key1, inner|
      inner.each do |key2, value|
        (result[key2] ||= {})[key1] = value
      end
    end
    result
  end

  def self.read_annotations
    path = File.join(Rails.root, "config", "study_annotations.yml")
    config = transposed(YAML::load(File.open(path)))
    config[:selections][:archivist] = lambda {
      User.archivists.map { |a| [a.name, a.id] }
    }
    config.each do |name, settings|
      define_method(name) do |column|
        value = settings[column.to_sym]
        value.is_a?(Proc) ? value.call(self, column) : value
      end
    end
  end

  read_annotations
end
