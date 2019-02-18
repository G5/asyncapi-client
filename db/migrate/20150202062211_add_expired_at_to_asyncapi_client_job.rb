class AddExpiredAtToAsyncapiClientJob < ActiveRecord::Migration[4.2]
  def change
    add_column :asyncapi_client_jobs, :expired_at, :datetime
  end
end
