class AddCallbackParamsToAsyncapiClientJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :asyncapi_client_jobs, :callback_params, :text
  end
end
