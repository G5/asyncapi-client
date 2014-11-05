module Asyncapi::Client
  class JobStatusWorker

    include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(job_id)
      job = Job.find(job_id)
      callback_method = "on_#{job.status}"
      return unless job.respond_to?(callback_method)
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
