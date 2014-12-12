# This migration comes from asyncapi_client (originally 20141119011011)
class AddCallbackParamsToAsyncapiClientJobs < ActiveRecord::Migration
  def change
    add_column :asyncapi_client_jobs, :callback_params, :text
  end
end
