class AttachmentsAddRestricted < ActiveRecord::Migration
  def up
    change_table :adapt_attachments do |t|
      t.boolean :restricted
    end
  end

  def down
    change_table :adapt_attachments do |t|
      remove_column :restricted
    end
  end
end
