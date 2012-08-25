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

ActiveRecord::Schema.define(:version => 20120823012051) do

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "entries", :force => true do |t|
    t.decimal  "hours"
    t.text     "notes"
    t.date     "cal_date"
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "entries", ["project_id"], :name => "index_entries_on_project_id"
  add_index "entries", ["user_id"], :name => "index_entries_on_user_id"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.text     "client"
    t.integer  "company_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.decimal  "budgeted_hrs"
  end

  add_index "projects", ["company_id"], :name => "index_projects_on_company_id"

  create_table "relationships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.decimal  "rate"
    t.date     "staffing_start"
    t.date     "staffing_end"
    t.decimal  "budgeted_hrs"
  end

  add_index "relationships", ["project_id"], :name => "index_relationships_on_project_id"
  add_index "relationships", ["user_id", "project_id"], :name => "index_relationships_on_user_id_and_project_id", :unique => true
  add_index "relationships", ["user_id"], :name => "index_relationships_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.integer  "company_id"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "name"
    t.string   "auth_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "active",                 :default => true
  end

  add_index "users", ["company_id"], :name => "index_users_on_company_id"

end
