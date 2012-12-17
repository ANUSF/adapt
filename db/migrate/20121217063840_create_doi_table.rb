class CreateDoiTable < ActiveRecord::Migration
  def up
    create_table :adapt_dois do |t|
      t.text   :title
      t.text   :creators
      t.string :publisher
      t.integer :year
      t.string :ddi_id
      t.string :doi
    end
  end

  def down
    drop_table :adapt_dois
  end
end
