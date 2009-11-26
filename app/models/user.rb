class User < ActiveRecord::Base
  attr_accessible(:username, :email, :name, :address, :telephone, :fax)

  # -- patterns for checking phone numbers
  SEP   = /( |-)?/
  WORLD = / \+\d{1,3} #{SEP} (\d|\(\d\)) #{SEP} \d{1,5} /xo
  AREA  = / \d{2,6} | \(\d{2,6}\) /xo
  LINE  = / \d{2,4} #{SEP} \d{4} /xo
  EXT   = /#{SEP}(ext|x)#{SEP}\d{1,5}/xo
  PHONE = /\A ((#{WORLD}|#{AREA}) #{SEP} #{LINE} #{EXT}?)? \Z/xo

  validates_format_of   :telephone, :with => PHONE,
                        :message => "Does not look like a phone number."
  validates_format_of   :fax, :with => PHONE,
                        :message => "Does not look like a phone number."

  has_many :studies, :dependent => :destroy

  def selections(column)
    %w{contributor archivist admin} if column.to_sym == :role
  end
end
