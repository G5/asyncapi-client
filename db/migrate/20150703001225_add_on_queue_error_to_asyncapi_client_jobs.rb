class AddOnQueueErrorToAsyncapiClientJobs < ActiveRecord::Migration
  def change
    add_column :asyncapi_client_jobs, :on_queue_error, :string
  end
end
