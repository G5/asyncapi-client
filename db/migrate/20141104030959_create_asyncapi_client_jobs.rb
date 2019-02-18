class CreateAsyncapiClientJobs < ActiveRecord::Migration[4.2]
  def change
    create_table :asyncapi_client_jobs do |t|
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
      t.timestamps
    end
  end
end
