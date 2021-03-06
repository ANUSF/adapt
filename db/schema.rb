# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121217063840) do

  create_table "adapt_attachments", :force => true do |t|
    t.integer  "study_id"
    t.string   "name"
    t.string   "category"
    t.string   "format"
    t.text     "stored_as"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "restricted"
  end

  create_table "adapt_dois", :force => true do |t|
    t.text    "title"
    t.text    "creators"
    t.string  "publisher"
    t.integer "year"
    t.string  "ddi_id"
    t.string  "doi"
  end

  create_table "adapt_licences", :force => true do |t|
    t.integer  "study_id"
    t.string   "access_mode"
    t.string   "signed_by"
    t.string   "email"
    t.string   "signed_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "adapt_studies", :force => true do |t|
    t.integer  "user_id"
    t.string   "permanent_identifier"
    t.string   "status"
    t.text     "title"
    t.text     "abstract"
    t.text     "additional_metadata"
    t.integer  "archivist_id"
    t.integer  "manager_id"
    t.string   "temporary_identifier"
    t.boolean  "skip_licence"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "identity_url"
    t.string   "username"
    t.string   "name"
    t.string   "email"
    t.string   "role"
    t.text     "address"
    t.string   "telephone"
    t.string   "fax"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["identity_url"], :name => "index_users_on_identity_url", :unique => true

end
