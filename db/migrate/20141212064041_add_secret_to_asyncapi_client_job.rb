class AddSecretToAsyncapiClientJob < ActiveRecord::Migration[4.2]
  def change
    add_column :asyncapi_client_jobs, :secret, :string
  end
end
