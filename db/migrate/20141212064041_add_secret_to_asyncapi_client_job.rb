class AddSecretToAsyncapiClientJob < ActiveRecord::Migration[5.0]
  def change
    add_column :asyncapi_client_jobs, :secret, :string
  end
end
