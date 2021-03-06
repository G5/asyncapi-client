module Asyncapi::Client
  class JobTimeOutWorker

    include Sidekiq::Worker

    sidekiq_options retry: false

    def perform
      Job.for_time_out.find_each { |job| time_out_job(job) }
    end

    private

    def time_out_job(job)
      job.update(status: :timed_out)
      ActiveRecord::Base.after_transaction do
        JobStatusWorker.perform_async(job.id)
      end
    end

  end
end

if Sidekiq.server?
  Sidekiq::Cron::Job.create({
    name: "Expire jobs",
    cron: "*/1 * * * *",
    klass: "Asyncapi::Client::JobTimeOutWorker",
  })
end
