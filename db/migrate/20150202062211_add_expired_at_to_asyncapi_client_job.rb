class AddExpiredAtToAsyncapiClientJob < ActiveRecord::Migration[5.0]
  def change
    add_column :asyncapi_client_jobs, :expired_at, :datetime
  end
end
