class Attachment < ActiveRecord::Base
  belongs_to :study

  attr_accessible :content, :category, :format, :description

  after_create :write_file
  before_destroy :delete_file

  def selections(column)
    if column.to_sym == :category
      [ "Data File", "Documentation" ]
    else
      []
    end
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
    assets = ENV['ADAPT_ASSET_PATH'] || RAILS_ROOT + "/assets"
    base = "#{assets}/studies/#{study.id}/attachments"
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
