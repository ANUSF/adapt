class Attachment < ActiveRecord::Base
  belongs_to :study

  attr_accessible :content, :category, :format, :description

  after_create :write_file
  before_destroy :delete_file

  validates_presence_of :content, :message => "No file given or file not found."
  validates_presence_of :description, :message => "Can't be blank."
  validates_presence_of :category, :message => "Please select one."

  def selections(column)
    column.to_sym == :category ? [ "Data File", "Documentation" ] : []
  end

  def empty_selection(column)
    column.to_sym == :category ? "-- Please select --" : false
  end

  def content=(uploaded)
    self.name = uploaded.original_filename
    @content = uploaded.read
  end

  def data
    File.open(stored_path) { |f| f.read }
  end

  protected

  def stored_path
    base = "#{ENV['ADAPT_ASSET_PATH']}/studies/#{study.id}/attachments"
    FileUtils.mkdir_p(base, :mode => 0755) unless File.exist? base
    "#{base}/#{stored_as}"
  end

  def write_file
    self.stored_as = "#{self.id}__#{self.name}"
    self.save!
    begin
      File.open(stored_path, "w", 0640) { |fp| fp.write(@content) }
    rescue Exception => ex
      delete_file
      raise ex
    end
  end

  def delete_file
    File.unlink stored_path if File.exist? stored_path
  end
end
