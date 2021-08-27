class PopulateAsyncapiClientJobExpiredAt < ActiveRecord::Migration[4.2]
  def change
    Asyncapi::Client::Job.find_each do |job|
      job.update(expired_at: Asyncapi::Client.expiry_threshold.from_now)
    end
  end
end
