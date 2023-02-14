module Asyncapi::Client
  class Job < ActiveRecord::Base

    after_initialize :generate_secret
    before_create :set_expired_at

    enum status: %i[queued success error timed_out fresh queue_error]
    serialize :headers, Hash
    serialize :callback_params, Hash

    include AASM
    aasm column: :status, enum: true do
      state :fresh, initial: true
      state :queued
      state :success
      state :error
      state :timed_out
      state :queue_error

      event :enqueue do
        transitions from: :fresh, to: :queued
      end

      event :succeed, after: :schedule_for_deletion do
        transitions from: :queued, to: :success
      end

      event :fail do
        transitions from: :queued, to: :error
      end

      event :time_out do
        transitions from: [:fresh, :queued], to: :timed_out
      end

      event :fail_queue do
        transitions from: :fresh, to: :queue_error
      end
    end

    scope :expired, -> { where(arel_table[:expired_at].lt(Time.now)) }
    scope :with_time_out, -> { where(arel_table[:time_out_at].not_eq(nil)) }
    scope :stale, -> (stale_duration = 5) do
      where(arel_table[:updated_at].lteq(stale_duration.minutes.ago)).
      where(status: statuses[:queued])
    end
    scope :for_time_out, -> do
      where(arel_table[:time_out_at].lt(Time.now)).
      where(status: [statuses[:queued], statuses[:fresh]])
    end

    def self.post(url,
                  kwargs ={ 
                  headers: nil,
                  body: nil,
                  on_queue: nil,
                  on_success: nil,
                  on_error: nil,
                  on_time_out: nil,
                  on_queue_error: nil,
                  callback_params: {},
                  follow_up: 5.minutes,
                  time_out: nil})

      args = {
        follow_up_at: kwargs[:follow_up].from_now,
        on_queue: kwargs[:on_queue],
        on_success: kwargs[:on_success],
        on_error: kwargs[:on_error],
        on_queue_error: kwargs[:on_queue_error],
        on_time_out: kwargs[:on_time_out],
        callback_params: kwargs[:callback_params],
        headers: kwargs[:headers],
        body: kwargs[:body],
      }
      args[:time_out_at] = kwargs[:time_out].from_now if kwargs[:time_out]
      job = create(args)
      ActiveRecord::Base.after_transaction do
        JobPostWorker.perform_async(job.id, url)
      end
    end

    def url
      Asyncapi::Client::Engine.routes.url_helpers.v1_job_url(self)
    end

    [:on_success, :on_error, :on_queue, :on_time_out, :on_queue_error].each do |attr|
      define_method("#{attr}=") do |klass|
        write_attribute attr, klass.to_s
      end
    end

    private

    def schedule_for_deletion
      if success?
        # delete in a couple of minutes, giving time for the success to be broadcasted
        JobCleanerWorker.perform_in(Asyncapi::Client.successful_jobs_deletion_after, self.id)
      end
    end

    def set_expired_at
      self.expired_at ||= Asyncapi::Client.expiry_threshold.from_now
    end

    def generate_secret
      self.secret ||= SecureRandom.uuid
    end

    def self.initial_state
      self.aasm.state_machine.initial_state
    end

    def self.non_initial_states
      self.aasm.states.reject do |state|
        state == initial_state
      end.map(&:name)
    end

  end
end
