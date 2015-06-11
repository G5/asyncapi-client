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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150611040554) do

  create_table "asyncapi_client_jobs", force: true do |t|
    t.string   "server_job_url"
    t.integer  "status"
    t.text     "message"
    t.datetime "follow_up_at"
    t.datetime "time_out_at"
    t.string   "on_queue"
    t.string   "on_success"
    t.string   "on_error"
    t.text     "body"
    t.text     "headers"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "callback_params"
    t.string   "secret"
    t.datetime "expired_at"
    t.string   "on_time_out"
  end

end
