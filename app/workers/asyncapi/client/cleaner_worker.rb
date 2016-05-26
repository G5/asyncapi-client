module Asyncapi
  module Client
    class CleanerWorker

      include Sidekiq::Worker
      sidekiq_options retry: false

      def perform
        Job.expired.find_each do |job|
          JobCleanerWorker.perform_async(job.id)
        end
      end

    end
  end
end

if Sidekiq.server?
  Sidekiq::Cron::Job.create({
    name: "Delete old jobs",
    cron: Asyncapi::Client.clean_job_cron,
    klass: Asyncapi::Client::CleanerWorker.name,
  })
end
