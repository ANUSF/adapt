class UnifyOpenids < ActiveRecord::Migration
  def self.up
    obsolete = []
    Adapt::User.all.group_by(&:username).each do |name, users|
      kept = users[0]
      for other in users[1..-1]
        other.studies.each { |s| kept.studies << s }
        obsolete << other.id
      end
    end
    obsolete.each { |n| User.find(n).destroy }
  end

  def self.down
  end
end
