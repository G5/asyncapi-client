# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_03_04_200630) do

  create_table "asyncapi_client_jobs", force: :cascade do |t|
    t.string "server_job_url"
    t.integer "status"
    t.text "message"
    t.datetime "follow_up_at"
    t.datetime "time_out_at"
    t.string "on_queue"
    t.string "on_success"
    t.string "on_error"
    t.text "body"
    t.text "headers"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "callback_params"
    t.string "secret"
    t.datetime "expired_at"
    t.string "on_time_out"
    t.integer "response_code"
    t.string "on_queue_error"
    t.index ["time_out_at"], name: "index_asyncapi_client_jobs_on_time_out_at"
  end

end
