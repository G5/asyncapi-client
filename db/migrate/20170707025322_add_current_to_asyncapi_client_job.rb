class AddCurrentToAsyncapiClientJob < ActiveRecord::Migration
  def change
    add_column :asyncapi_client_jobs, :current, :boolean
  end
end
