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
