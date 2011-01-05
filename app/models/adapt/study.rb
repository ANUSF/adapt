class Adapt::Study < ActiveRecord::Base
  set_table_name 'adapt_studies'

  User = Adapt::User
  Attachment = Adapt::Attachment
  Licence = Adapt::Licence

  ID_PREFIX = "au.edu.assda.ddi."

  include Adapt::ModelSupport
  include Adapt::FileHandling
  include Adapt::JsonAccessors

  belongs_to :owner,     :class_name => 'User', :foreign_key => :user_id
  belongs_to :archivist, :class_name => 'User', :foreign_key => :archivist_id
  belongs_to :manager,   :class_name => 'User', :foreign_key => :manager_id
  has_many   :attachments, :dependent => :destroy
  has_one    :licence ,    :dependent => :destroy
  accepts_nested_attributes_for :licence
  accepts_nested_attributes_for :attachments, :allow_destroy => true

  before_create { |rec| rec.archivist = rec.owner if rec.owner.is_archivist }

  before_save { |rec| rec.attachments.each { |a| a.destroy if a.extracted } }

  JSON_FIELDS = [:data_is_qualitative, :data_is_quantitative, :data_kind,
                 :data_relation, :time_method, :sample_population,
                 :sampling_procedure, :collection_method, :collection_start,
                 :collection_end, :period_start, :period_end, :response_rate,
                 :depositors, :principal_investigators, :data_producers,
                 :funding_agency, :other_acknowledgements, :references]

  attr_accessible(*(JSON_FIELDS +
                    [:title,
                     :abstract,
                     :uploads_attributes,
                     :attachments_attributes,
                     :licence_attributes,
                     :skip_licence,
                     :additional_metadata,
                     :data_kind_items_attributes,
                     :time_method_items_attributes,
                     :sampling_procedure_items_attributes,
                     :collection_method_items_attributes,
                     :depositors_items_attributes,
                     :principal_investigators_items_attributes,
                     :data_producers_items_attributes,
                     :funding_agency_items_attributes,
                     :other_acknowledgements_items_attributes,
                     :references_items_attributes
                    ]))

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
    elsif val['name'].blank?
      rec.errors.add attr,
      'Please use the name field if depositor is an institution.'
    end
  end

  validates_each :principal_investigators, :if => :checking do |rec, attr, val|
    if val.blank?
      rec.errors.add attr, 'Please list at least one.'
    elsif val.any? { |pi| pi['name'].blank? }
      rec.errors.add attr, 'Please use the name field if p.i. is an institution.'
    end
  end

  attr_reader :checking

  self.json_column_name = :additional_metadata
  json_fields(*JSON_FIELDS)

  # We override this to prevent premature destruction of ZIP attachments.
  def update_attributes(attributes)
    (attributes['attachments_attributes'] || {}).each do |key, value|
      value['_destroy'] = '0' if value['extract'] == '1'
    end
    super
  end

  # Virtual attributes
  def uploads
    [Attachment.new]
  end

  def uploads_attributes=(data)
    data.each do |k, params|
      unless params[:content].blank? or params[:use] == "0"
        attachments.create(params)
      end
    end
  end

  def subfields_for_nesting(attr)
    (subfields(attr.to_s) || ['value']).map(&:to_sym)
  end

  %w{data_kind time_method sampling_procedure collection_method
     depositors principal_investigators data_producers
     funding_agency other_acknowledgements references}.each do |attr|

    define_method("#{attr}_items") do
      fields = subfields(attr)
      default = fields.blank? ? '' : Hash[*fields.zip([]).flatten]
      data = if is_repeatable?(attr)
               (send(attr) || []) + [default]
             else
               [send(attr) || default]
             end
      data.map { |val| Adapt::Generic.new(val) }
    end

    define_method("#{attr}_items_attributes=") do |data|
      params = data.values
      fields = subfields(attr)
      value = if fields.blank? then params.map { |p| p[:value] } else params end
      send "#{attr}=", is_repeatable?(attr) ? value : value[0]
    end
  end

  # Status test
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
    %w{submitted approved stored}.include? status
  end

  def is_owned_by(person)
    person.is_a? User and owner and person.id == owner.id
  end

  def is_curated_by(person)
    person.is_a? User and person.is_archivist and
      archivist and person.id == archivist.id
  end

  def can_be_viewed_by(person)
    person and (person.is_archivist or is_owned_by(person))
  end

  def is_listed_for(person)
    person and (is_owned_by(person) or
                (person.is_archivist and is_curated_by(person)) or
                (person.is_admin and is_submitted))
  end

  def can_be_edited_by(person)
    if person and person.is_archivist
      #TODO change this when editing of approved studies works correctly
      is_curated_by(person) and not is_submitted
    else
      is_owned_by(person) and not is_submitted
    end
  end

  def can_be_destroyed_by(person)
    can_be_edited_by(person) and not is_submitted
  end

  def can_be_submitted_by(person)
    person and (is_owned_by(person) or is_curated_by(person))
  end
  
  def can_be_approved_by(person)
    person and person.is_admin and status == 'submitted' and archivist.nil?
  end
  
  def can_be_stored_by(person)
    person and (is_curated_by(person) or person.is_admin) and
      ( %w{submitted approved}.include? status or 
        ( status == 'stored' and permanent_identifier.starts_with? 'test') )
  end

  def can_be_managed_by(person)
    person and (is_curated_by(person) or person.is_admin)
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
    av = ActionView::Base.new(*Rails.configuration.paths.app.views)
    av.extend Adapt::StudiesHelper
    av.assign :study => self, :identifier => (with_id || self.identifier)
    av.render 'adapt/studies/ddi.xml'
  end

  def submit(licence_text)
    Rails.logger.info 'Creating a temporary study id'
    ident = create_unique_id_and_directory(submission_path, "deposit_", 1..99999)
    self.temporary_identifier = ident.sub(/_/, ':')

    Rails.logger.info 'Writing the files'
    write_files_on_submission(licence_text, File.join(submission_path, ident))

    Rails.logger.info 'Saving the record'
    self.status = "submitted"
    save!

    unless owner.is_archivist
      begin
        Adapt::UserMailer.submission_notification(self).deliver
      rescue Exception => ex
        Rails.logger.info 'Failed to send notification email.'
        Rails.logger.error(ex.to_s + "\n" + ex.backtrace[0..50].join("\n"))
      else
        Rails.logger.info 'Notification email was sent.'
      end
    end
  end

  def approve(assigned_archivist)
    Rails.logger.info 'Assigning study to archivist'
    self.status = "approved"
    self.archivist = assigned_archivist
    save!

    begin
      Adapt::UserMailer.archivist_assignment(self).deliver
    rescue
      Rails.logger.info 'Failed to send notification email.'
    else
      Rails.logger.info 'Notification email was sent.'
    end
  end

  def handover(new_archivist)
    former_archivist = archivist
    Rails.logger.info 'Handing over study'
    self.archivist = new_archivist
    save!

    begin
      Adapt::UserMailer.handover_notification(self, former_archivist).deliver
    rescue
      Rails.logger.info 'Failed to send notification email.'
    else
      Rails.logger.info 'Notification email was sent.'
    end
  end

  def store(range = '0')
    Rails.logger.info 'Creating a study id'
    self.permanent_identifier = create_permanent_id(range)

    Rails.logger.info 'Writing the files'
    base = File.join(archive_path, permanent_identifier)
    make_fresh_directory(base, "Original")
    make_fresh_directory(base, "Original", "Processing")
    write_files_on_approval(read_licence_file, File.join(base, "Original"))

    write_file(["StudyID=#{identifier}",
                "Title=#{title}",
                "#{long_identifier}=#{title}"].join("\r\n") + "\r\n",
               base, "contents.txt")

    Rails.logger.info 'Saving the record'
    self.status = 'stored'
    save!

    unless identifier.starts_with?('test')
      begin
        Adapt::UserMailer.approval_notification(self).deliver
      rescue
        Rails.logger.info 'Failed to send notification email.'
      else
        Rails.logger.info 'Notification email was sent.'
      end
    end
  end

  def reopen
    self.status = "unsubmitted"
    save
  end

  protected

  def create_permanent_id(range)
    if range == 'T'
      create_unique_id_and_directory(archive_path, 'test', 99000..99999)
    else
      effective_range =
        case range
        when '0'
          1..7999
        when /[1-9]/
          n = range.to_i * 10000
          n..(n+9999)
        else
          raise 'Invalid range.'
        end
      create_unique_id_and_directory(archive_path, '', effective_range)
    end
  end

  def read_licence_file
    read_file(submission_path, temporary_identifier.sub(/:/, '_'), "Licence.txt")
  end

  def write_files_on_submission(licence_text, base)
    write_file(licence_text, base, "Licence.txt") unless licence_text.blank?
    write_file(ddi, base, "Study.xml")

    attachments.each do |a|
      write_file(a.data, base, a.category.gsub(/\s/, '').pluralize, a.name)
    end
    write_file(attachments.map { |a| a.metadata.to_yaml }.join("\n"),
               base, "FileDescriptions.txt")
  end

  def write_files_on_approval(licence_text, base)
    licence_file = "ASSDA.Deposit.Licence.#{identifier}.txt"
    write_file(licence_text, base, licence_file) unless licence_text.blank?
    write_file(ddi, base, "#{long_identifier}.xml")

    filedata = attachments.map do |a|
      path = non_conflicting(File.join(base, a.name))
      write_file(a.data, path)
      a.metadata.merge("Filename" => File.basename(path), "Original" => a.name
                       ).to_yaml
    end
    write_file(filedata.join("\n").split("\n").join("\r\n") + "\r\n",
               base, "Processing", "FileDescriptions.txt")
  end

  def submission_path
    File.join(ADAPT::CONFIG['adapt.asset.path'], "Submission")
  end

  def archive_path
    ADAPT::CONFIG['adapt.archive.path']
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

  def self.set_annotations
    path = File.join(Rails.root, "config", "study_annotations.yml")
    config = transposed(YAML::load(File.open(path)))

    config[:selections][:archivist] = lambda { |item, col|
      [["", nil]] + User.archivists.map { |a| [a.name, a.id] }
    }
    config[:selections][:id_range] =
      [["", nil], "Test only"] + "0234".each_char.map { |i| "#{i}0000-#{i}9999" }

    config.each do |name, settings|
      define_method(name) do |column|
        value = settings[column.to_sym]
        value.is_a?(Proc) ? value.call(self, column) : value
      end
    end
  end

  set_annotations
end
