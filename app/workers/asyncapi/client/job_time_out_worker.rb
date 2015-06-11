module Asyncapi::Client
  class JobTimeOutWorker

    include Sidekiq::Worker
    include Sidetiq::Schedulable

    sidekiq_options retry: false

    recurrence { minutely }

    def perform
      Job.for_time_out.find_each do |job|
        time_out_job(job) if job.may_time_out?
      end
    end

    private

    def time_out_job(job)
      job.update_attributes(status: :timed_out)
      JobStatusWorker.perform_async(job.id)
    end

  end
end
