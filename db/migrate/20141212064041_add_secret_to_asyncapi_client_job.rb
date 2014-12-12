class AddSecretToAsyncapiClientJob < ActiveRecord::Migration
  def change
    add_column :asyncapi_client_jobs, :secret, :string
  end
end
