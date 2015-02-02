module Asyncapi::Client
  class Job < ActiveRecord::Base

    after_initialize :generate_secret
    before_create :set_expired_at

    enum status: %i[queued success error]
    serialize :headers, Hash
    serialize :callback_params, Hash

    scope :expired, -> { where(arel_table[:expired_at].lt(Time.now)) }

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
      CleanerWorker.perform_async
    end

    def url
      Asyncapi::Client::Engine.routes.url_helpers.v1_job_url(self)
    end

    def body=(body)
      json = body.is_a?(Hash) ? body.to_json : body
      write_attribute :body, json
    end

    [:on_success, :on_error, :on_queue].each do |attr|
      define_method("#{attr}=") do |klass|
        write_attribute attr, klass.to_s
      end
    end

    private

    def set_expired_at
      self.expired_at ||= Asyncapi::Client.expiry_threshold.from_now
    end

    def generate_secret
      self.secret ||= SecureRandom.uuid
    end

  end
end
