# This migration comes from asyncapi_client (originally 20141212064041)
class AddSecretToAsyncapiClientJob < ActiveRecord::Migration
  def change
    add_column :asyncapi_client_jobs, :secret, :string
  end
end
