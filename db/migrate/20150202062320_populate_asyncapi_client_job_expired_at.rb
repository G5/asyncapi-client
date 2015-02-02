class PopulateAsyncapiClientJobExpiredAt < ActiveRecord::Migration
  def change
    Asyncapi::Client::Job.find_each do |job|
      job.update_attributes(expired_at: Asyncapi::Client.expiry_threshold.from_now)
    end
  end
end
