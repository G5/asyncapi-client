module Asyncapi::Client
  class JobStatusWorker

    include Sidekiq::Worker
    sidekiq_options retry: false

    STATUS_CALLBACK_MAP = {
      queued: :on_queue,
      success: :on_success,
      error: :on_error,
      timed_out: :on_time_out,
      queue_error: :on_queue_error,
    }.with_indifferent_access

    def perform(job_id)
      job = Job.find(job_id)
      callback_method = STATUS_CALLBACK_MAP[job.status]
      return if callback_method.nil?
      class_name = job.send(callback_method)
      begin
        callback_class = class_name.constantize
      rescue NameError
        return
      end
      callback_class.call(job.id)
    end

  end
end
