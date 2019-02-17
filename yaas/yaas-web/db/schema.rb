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

ActiveRecord::Schema.define(:version => 20120831210605) do

  create_table "activations", :force => true do |t|
    t.integer  "user_id"
    t.text     "comments"
    t.integer  "bucket"
    t.text     "data",       :limit => 16777215
    t.string   "method"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blacklists", :force => true do |t|
    t.string   "serial_number"
    t.text     "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.boolean  "admin"
    t.string   "email"
    t.integer  "bucket"
    t.integer  "activation_limit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "can_create_dev_keys", :default => false
    t.string   "password_hash"
  end

end
