class AddResponseCodeToAsyncapiClientJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :asyncapi_client_jobs, :response_code, :integer
  end
end
