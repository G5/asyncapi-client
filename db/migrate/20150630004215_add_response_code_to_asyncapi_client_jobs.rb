class AddResponseCodeToAsyncapiClientJobs < ActiveRecord::Migration[4.2]
  def change
    add_column :asyncapi_client_jobs, :response_code, :integer
  end
end
