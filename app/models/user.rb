class User < ActiveRecord::Base
  has_many :studies, :dependent => :destroy
  has_many :studies_in_curation,  :class_name  => 'Study',
                                  :foreign_key => :archivist_id
  has_many :studies_for_approval, :class_name  => 'Study',
                                  :foreign_key => :manager_id

  attr_accessible(:email, :name, :address, :telephone, :fax)

  named_scope :archivists, :conditions => 'role != "contributor"'

  # -- the possible roles for a user
  ROLES = %w{contributor archivist admin}

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

  def selections(column)
    ROLES if column.to_sym == :role
  end

  def is_admin
    %w{archivist admin}.include? role
  end
end
