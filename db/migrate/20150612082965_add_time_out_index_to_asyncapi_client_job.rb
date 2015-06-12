class AddTimeOutIndexToAsyncapiClientJob < ActiveRecord::Migration
  def change
    add_index :asyncapi_client_jobs, :time_out_at
  end
end
