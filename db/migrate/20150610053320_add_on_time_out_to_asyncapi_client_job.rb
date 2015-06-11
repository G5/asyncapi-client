class AddOnTimeOutToAsyncapiClientJob < ActiveRecord::Migration
  def change
    add_column :asyncapi_client_jobs, :on_time_out, :string
  end
end
