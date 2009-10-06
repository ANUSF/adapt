# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091006052755) do

  create_table "studies", :id => false, :force => true do |t|
    t.integer  "id",                   :limit => nil, :null => false
    t.integer  "user_id",                             :null => false
    t.string   "permanent_identifier",                :null => false
    t.string   "name",                                :null => false
    t.string   "status",                              :null => false
    t.string   "title",                :limit => nil, :null => false
    t.string   "abstract",             :limit => nil, :null => false
    t.string   "additional_metadata",  :limit => nil, :null => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  create_table "users", :id => false, :force => true do |t|
    t.integer  "id",                :limit => nil, :null => false
    t.string   "username",                         :null => false
    t.string   "email",                            :null => false
    t.string   "crypted_password",                 :null => false
    t.string   "password_salt",                    :null => false
    t.string   "persistence_token",                :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "name",                             :null => false
    t.string   "address",           :limit => nil, :null => false
    t.string   "telephone",                        :null => false
    t.string   "fax",                              :null => false
  end

end
