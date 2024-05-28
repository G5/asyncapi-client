module Asyncapi
  module Client
    class JobCleanerWorker

      include Sidekiq::Worker

      def perform(job_id)
        if job = Job.find_by(id: job_id)
          destroy_remote(job)
          job.destroy
        end
      end

      private

      def destroy_remote(job)
        unless url_ok_for?(job)
          # Typhoeus needs a server_job_url to destroy a job, but if a job for whatever reason does not have one
          # it will never be destroyed and the sidekiq queue will just fill up and keep retrying
          job.destroy 
        end
        errors = validate_remote_job_info(job)
        if errors.empty?
          response = Typhoeus.delete(job.server_job_url, {
            params: { secret: job.secret },
            headers: job.headers,
          })

          raise response.body unless response.success?
        else
          raise log_remote_error_for(job, errors)
        end
      end

      def validate_remote_job_info(job)
        errors = []
        errors << "server_job_url is invalid"         unless url_ok_for?(job)
        errors << "authorization headers are not present" unless headers_ok_for?(job)
        errors << "secret is not present"                unless job.secret.present?
        errors
      end

      def url_ok_for?(job)
        uri = URI.parse(job.server_job_url)
        uri.is_a?(URI::HTTP) && !uri.host.nil?
      rescue URI::InvalidURIError
        false
      end

      def headers_ok_for?(job)
        job.headers.is_a?(Hash) && job.headers[:AUTHORIZATION]
      end

      def log_remote_error_for(job, errors)
        [
          "origin: #{self.class.name}#destroy_remote",
          "external_parent_id: #{job.id}",
          "message: Not enough info to delete expired remote job: #{errors.join(", ")}",
          "error: Unable to delete remote job",
        ].join(',')
      end
    end
  end
end
