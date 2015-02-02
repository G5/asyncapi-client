module Asyncapi
  module Client
    class JobCleanerWorker

      include Sidekiq::Worker
      sidekiq_options retry: false

      def perform(job_id)
        if job = Job.find_by(id: job_id)
          destroy_remote job
          job.destroy
        end
      end

      private

      def destroy_remote(job)
        Typhoeus.delete(job.server_job_url, {
          params: { secret: job.secret },
        })
      end

    end
  end
end
