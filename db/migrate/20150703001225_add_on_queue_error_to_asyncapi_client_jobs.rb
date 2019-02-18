class AddOnQueueErrorToAsyncapiClientJobs < ActiveRecord::Migration[4.2]
  def change
    add_column :asyncapi_client_jobs, :on_queue_error, :string
  end
end
