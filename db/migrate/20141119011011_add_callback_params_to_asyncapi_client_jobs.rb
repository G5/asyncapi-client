class AddCallbackParamsToAsyncapiClientJobs < ActiveRecord::Migration[4.2]
  def change
    add_column :asyncapi_client_jobs, :callback_params, :text
  end
end
