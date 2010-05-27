class Attachment < ActiveRecord::Base
  ASSET_PATH = ADAPT::CONFIG['adapt.asset.path']

  include ActionView::Helpers::NumberHelper
  include FileHandling

  belongs_to :study

  attr_accessible :content, :category, :format, :description

  after_create :write_data
  before_destroy :delete_file

  validates_inclusion_of :category, :if => :checking,
    :in => ['Data File', 'Documentation'],
    :message => "Please select one."

  attr_reader :checking

  def selections(column)
    column.to_sym == :category ? [ "Documentation", "Data File" ] : []
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
  
  def self.make(name, data)
    self.new(:content => Struct.new(:original_filename, :read).new(name, data))
  end

  protected

  def ready_for_submission?
    @checking = true
    result = valid?
    @checking = false
    result
  end

  def validate_on_create
    if self.name.blank?
      errors.add("content", "Please select a file.")
    elsif @content.blank?
      errors.add("content", "The selected file '#{self.name}' seems empty.")
    end
    super
  end

  def stored_path
    File.join(ASSET_PATH, "Temporary", study.owner.username,
              study.id.to_s, "files", stored_as)
  end

  def write_data
    self.stored_as = "#{self.id}__#{self.name}"
    self.save!
    write_file(@content, stored_path)
  end

  def delete_file
    File.unlink stored_path if File.exist? stored_path
  end
end
