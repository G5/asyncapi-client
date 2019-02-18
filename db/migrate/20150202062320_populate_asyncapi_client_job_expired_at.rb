class PopulateAsyncapiClientJobExpiredAt < ActiveRecord::Migration[5.0]
  def change
    Asyncapi::Client::Job.find_each do |job|
      job.update_attributes(expired_at: Asyncapi::Client.expiry_threshold.from_now)
    end
  end
end
