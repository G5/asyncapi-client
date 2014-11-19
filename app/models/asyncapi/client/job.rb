module Asyncapi::Client
  class Job < ActiveRecord::Base

    enum status: %i[queued success error]
    serialize :headers, Hash
    serialize :callback_params, Hash

    def self.post(url, headers: nil, body: nil,
                  on_queue: nil, on_success: nil, on_error: nil,
                  callback_params: {},
                  follow_up: 5.minutes, time_out: 30.minutes)
      job = create(
        follow_up_at: follow_up.from_now,
        time_out_at: time_out.from_now,
        on_queue: on_queue,
        on_success: on_success,
        on_error: on_error,
        callback_params: callback_params,
        headers: headers,
        body: body,
      )
      JobPostWorker.perform_async(job.id, url)
    end

    def url
      Asyncapi::Client::Engine.routes.url_helpers.v1_job_url(self)
    end

    def body=(body)
      json = body.is_a?(Hash) ? body.to_json : body
      write_attribute :body, json
    end

  end
end
