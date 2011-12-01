class Adapt::Attachment < ActiveRecord::Base
  set_table_name 'adapt_attachments'

  ASSET_PATH = ADAPT::CONFIG['adapt.asset.path']

  VALID_CATEGORIES = ["Data File", "Questionnaire", "Report", "Coding Frame",
                      "Codebook", "Notes", "Other Documentation"]

  include ActionView::Helpers::NumberHelper
  include Adapt::FileHandling

  belongs_to :study

  attr_accessible :content, :category, :restricted, :format, :description,
    :extract

  attr_reader :extracted, :checking

  scope :data_files, :conditions => { :category => 'Data File' }

  after_create :move_tmp_file
  before_destroy :delete_file

  validates_inclusion_of :category, :if => :checking, :in => VALID_CATEGORIES,
  :message => "Please select one."

  validates :name, :on => :create,
  :presence => { :message => "Please select a file." }

  def empty_selection(column)
    column.to_sym == :category ? '-- Please select --' : nil
  end

  def selections(column)
    column.to_sym == :category ? VALID_CATEGORIES : []
  end

  def label_for(column)
    column.to_sym == :category ? "Data File" : nil
  end

  def content=(uploaded)
    self.name = uploaded.original_filename
    info = write_file(uploaded, ASSET_PATH, "Temporary", "adapt_upload")
    @tmp_path = info[:path]
    self.stored_as = "#{info[:hash]}__#{name}"
  end

  def data
    read_file(stored_path)
  end

  def size
    File.size stored_path
  end

  def file_type
    name.sub /.*\./, '' if name.index '.'
  end

  def description_for_ddi
    description.blank? ? name : description
  end

  def metadata
    { "Filename" => name,
      "Filesize" => number_to_human_size(size),
      "Category" => category,
      "Comments" => description }
  end
  
  def extract
  end

  def extract=(value)
    if name.ends_with?('.zip') and value == '1' and not @extracted
      Zip::ZipInputStream::open(stored_path) do |io|
        while (entry = io.get_next_entry)
          name = File.basename(entry.name)
          study.attachments << Adapt::Attachment.make(name, io.read)
        end
      end
      @extracted = true
    end
  end

  def self.make(name, data)
    self.new(:content => Struct.new(:original_filename, :read).new(name, data))
  end

  def ready_for_submission?
    @checking = true
    result = valid?
    @checking = false
    result
  end

  protected

  def stored_path
    File.join(ASSET_PATH, "Temporary", study.owner.username, study.id.to_s,
              "files", stored_as)
  end

  def delete_file
    File.unlink stored_path if File.exist? stored_path
  end

  def move_tmp_file
    File.rename @tmp_path, stored_path
  end
end
