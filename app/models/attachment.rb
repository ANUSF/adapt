class Attachment < ActiveRecord::Base
  attr_accessible :content, :category, :format, :description

  after_create :write_file
  before_destroy :delete_file

  def content=(uploaded)
    self.name = uploaded.original_filename
    @content = uploaded.read
  end

  protected

  def stored_path
    base = (ENV['ADAPT_ASSET_PATH'] || RAILS_ROOT + "/assets") + "/attachments"
    FileUtils.mkdir_p base unless File.exist? base
    "#{base}/#{stored_as}"
  end

  def write_file
    self.stored_as = "#{self.id}"
    self.save!
    begin
      File.open(stored_path, "w") { |fp| fp.write(@content) }
    rescue Exception => ex
      delete_file
      raise ex
    end
  end

  def delete_file
    File.unlink stored_path if File.exist? stored_path
  end
end
