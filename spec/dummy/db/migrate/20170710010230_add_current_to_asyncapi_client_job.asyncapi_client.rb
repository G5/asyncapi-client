# This migration comes from asyncapi_client (originally 20170707025322)
class AddCurrentToAsyncapiClientJob < ActiveRecord::Migration
  def change
    add_column :asyncapi_client_jobs, :current, :boolean
  end
end
