class AddExpiredAtIndexToAsyncapiClientJobs < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def change
    # opts = {}
    # if !!(ActiveRecord::Base.connection_config[:adapter] =~ /postgresql/i)
    #   opts[:algorithm] = :concurrently
    # end
    # binding.pry
    add_index :asyncapi_client_jobs, :expired_at #, opts
  end
end
