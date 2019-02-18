class AddExpiredAtIndexToAsyncapiClientJobs < ActiveRecord::Migration[5.0]
  def change
    add_index :asyncapi_client_jobs, :expired_at
  end
end
