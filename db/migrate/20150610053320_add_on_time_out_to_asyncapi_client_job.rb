class AddOnTimeOutToAsyncapiClientJob < ActiveRecord::Migration[4.2]
  def change
    add_column :asyncapi_client_jobs, :on_time_out, :string
  end
end
