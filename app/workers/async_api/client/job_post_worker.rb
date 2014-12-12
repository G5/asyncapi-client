module Asyncapi::Client
  class JobPostWorker

    include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(job_id, server_url)
      job = Job.find(job_id)
      server_params = server_params_from(job, job.body)
      response = Typhoeus.post(server_url, {
        body: server_params,
        headers: job.headers,
      })
      process response, job
    end

    private

    def process(response, job)
      if response.success? && job.update_attributes(job_params_from(response))
        JobStatusWorker.perform_async(job.id)
      else
        job.update_attributes(status: :error, message: response.body)
      end
    end

    def job_params_from(response)
      response_body = JSON.parse(response.body).with_indifferent_access
      server_job_params = response_body[:job]
      server_job_params.slice(:status).
        merge(server_job_url: server_job_params[:url])
    end

    def server_params_from(job, params)
      {
        job: {
          callback_url: job.url,
          params: params,
          secret: job.secret,
        }
      }
    end

  end
end
