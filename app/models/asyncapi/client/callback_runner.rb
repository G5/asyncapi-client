module Asyncapi::Client
  class CallbackRunner

    attr_accessor :job_id
    DELEGATED_ATTRS = [
      :callback_params,
      :body,
      :headers,
      :message,
      :response_code,
    ]
    delegate *DELEGATED_ATTRS, to: :job

    def self.call(job_id)
      self.new(job_id).call
    end

    def initialize(job_id)
      self.job_id = job_id
    end

    def call
      fail StandardError, "over-ride me"
    end

    def job
      @job ||= Job.find(job_id)
    end

  end
end
