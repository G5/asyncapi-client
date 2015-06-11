module Asyncapi::Client
  class Job < ActiveRecord::Base

    after_initialize :generate_secret
    before_create :set_expired_at

    enum status: %i[queued success error timed_out fresh]
    serialize :headers, Hash
    serialize :callback_params, Hash

    include AASM
    aasm column: :status, enum: true do
      state :fresh, initial: true
      state :queued
      state :success
      state :error
      state :timed_out

      event :enqueue do
        transitions from: :fresh, to: :queued
      end

      event :succeed do
        transitions from: :queued, to: :success
      end

      event :fail do
        transitions from: :queued, to: :error
      end

      event :time_out do
        transitions from: [:fresh, :queued], to: :timed_out
      end
    end

    scope :expired, -> { where(arel_table[:expired_at].lt(Time.now)) }
    scope :with_time_out, -> { where(arel_table[:time_out_at].not_eq(nil)) }
    scope :for_time_out, -> do
      with_time_out.where(arel_table[:time_out_at].lt(Time.now))
    end

    def self.post(url,
                  headers: nil,
                  body: nil,
                  on_queue: nil,
                  on_success: nil,
                  on_error: nil,
                  on_time_out: nil,
                  callback_params: {},
                  follow_up: 5.minutes,
                  time_out: nil)

      job = create(
        follow_up_at: follow_up.from_now,
        time_out_at: time_out.from_now,
        on_queue: on_queue,
        on_success: on_success,
        on_error: on_error,
        on_time_out: on_time_out,
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

    [:on_success, :on_error, :on_queue, :on_time_out].each do |attr|
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
