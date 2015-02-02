# This migration comes from asyncapi_client (originally 20150202062211)
class AddExpiredAtToAsyncapiClientJob < ActiveRecord::Migration
  def change
    add_column :asyncapi_client_jobs, :expired_at, :datetime
  end
end
