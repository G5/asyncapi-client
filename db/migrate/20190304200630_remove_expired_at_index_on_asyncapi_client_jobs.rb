class RemoveExpiredAtIndexOnAsyncapiClientJobs < ActiveRecord::Migration[5.0]
  def change
    remove_index :asyncapi_client_jobs, :expired_at
  end
end
