class AddExpiredAtIndexToAsyncapiClientJobs < ActiveRecord::Migration[5.0]
# class AddExpiredAtIndexToAsyncapiClientJobs < ActiveRecord::Migration
  def change
    def change
      add_index :asyncapi_client_jobs, :expired_at
    end
  end
end
