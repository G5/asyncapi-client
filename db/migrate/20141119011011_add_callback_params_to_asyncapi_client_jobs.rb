class AddCallbackParamsToAsyncapiClientJobs < ActiveRecord::Migration
  def change
    add_column :asyncapi_client_jobs, :callback_params, :text
  end
end
