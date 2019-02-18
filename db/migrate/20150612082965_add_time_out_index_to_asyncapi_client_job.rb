class AddTimeOutIndexToAsyncapiClientJob < ActiveRecord::Migration[5.0]
  def change
    add_index :asyncapi_client_jobs, :time_out_at
  end
end
