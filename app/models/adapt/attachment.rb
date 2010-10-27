class Adapt::Attachment < ActiveRecord::Base
  ASSET_PATH = ADAPT::CONFIG['adapt.asset.path']

  VALID_CATEGORIES = ["Data File", "Questionnaire", "Report", "Coding Frame",
                      "Codebook", "Notes", "Other Documentation"]

  include ActionView::Helpers::NumberHelper
  include Adapt::FileHandling

  belongs_to :study

  attr_accessible :content, :category, :format, :description, :extract

  attr_reader :extracted, :checking, :content

  after_create :write_data
  before_destroy :delete_file

  validates_inclusion_of :category, :if => :checking, :in => VALID_CATEGORIES,
  :message => "Please select one."

  validates :name, :on => :create,
  :presence => { :message => "Please select a file." }

  validates :content, :on => :create,
  :presence => { :message => "The selected file '#{self.name}' seems empty." }

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
    @content = uploaded.read
  end

  def data
    read_file(stored_path)
  end

  def metadata
    { "Filename" => name,
      "Filesize" => number_to_human_size(data.size),
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
          study.attachments << Attachment.make(name, io.read)
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

  def path_components
    [ASSET_PATH, "Temporary",
     study.owner.username, study.id.to_s, "files", stored_as]
  end

  def stored_path
    File.join(*path_components)
  end

  def write_data
    self.stored_as = "#{self.id}__#{self.name}"
    self.save!
    write_file(@content, *path_components)
  end

  def delete_file
    File.unlink stored_path if File.exist? stored_path
  end
end
