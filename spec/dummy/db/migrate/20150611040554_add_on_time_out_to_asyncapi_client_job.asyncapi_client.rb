# This migration comes from asyncapi_client (originally 20150610053320)
class AddOnTimeOutToAsyncapiClientJob < ActiveRecord::Migration
  def change
    add_column :asyncapi_client_jobs, :on_time_out, :string
  end
end
