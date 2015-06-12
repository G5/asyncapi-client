# This migration comes from asyncapi_client (originally 20150612082965)
class AddTimeOutIndexToAsyncapiClientJob < ActiveRecord::Migration
  def change
    add_index :asyncapi_client_jobs, :time_out_at
  end
end
