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

  validates :stored_as, :on => :create, :uniqueness => {
    :scope => :study_id,
    :message => "This attachment already exists." }

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

  def open(&block)
    File.open(stored_path, 'rb', &block)
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
  
  class StreamContent
    def initialize(stream, name)
      @name = name
      @stream = stream
    end

    def original_filename
      @name
    end

    def read(*args)
      @stream.read *args
    end
  end

  def extract
  end

  def extract=(value)
    if name.ends_with?('.zip') and value == '1' and not @extracted
      Zip::ZipInputStream::open(stored_path) do |io|
        while (entry = io.get_next_entry)
          name = File.basename(entry.name)
          study.attachments.create(:content => StreamContent.new(io, name))
        end
      end
      @extracted = true
    end
  end

  def ready_for_submission?
    @checking = true
    result = valid?
    @checking = false
    result
  end

  def stored_path
    File.join(*path_components)
  end

  protected

  def path_components
    [ASSET_PATH, "Temporary", study.owner.username, study.id.to_s, "files",
     stored_as]
  end

  def delete_file
    File.unlink stored_path if File.exist? stored_path
  end

  def move_tmp_file
    move_file @tmp_path, *path_components
  end
end
