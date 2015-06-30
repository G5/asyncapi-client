class AddStatusCodeToAsyncapiClientJobs < ActiveRecord::Migration
  def change
    add_column :asyncapi_client_jobs, :response_code, :integer
  end
end
