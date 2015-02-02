class AddExpiredAtToAsyncapiClientJob < ActiveRecord::Migration
  def change
    add_column :asyncapi_client_jobs, :expired_at, :datetime
  end
end
