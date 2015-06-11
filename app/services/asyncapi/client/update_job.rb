module Asyncapi::Client
  class UpdateJob

    def self.execute(job: job, params: params)
      sanitized_params = params.reject { |key, value| key.to_sym == :status }
      job.assign_attributes(sanitized_params)
      status = params[:status]

      if may_transition?(job, to: status)
        transition(job, to: status)
        if job.status_changed? && job.save
          JobStatusWorker.perform_async(job.id)
        else
          job.save
        end
      elsif !may_transition?(job, to: status) && job.status == status
        job.save
      end
    end

    private

    def self.event_for(status)
      case status
      when "success"; :succeed
      when "error"; :fail
      end
    end

    def self.may_transition?(job, to:)
      job.send(:"may_#{event_for(to)}?")
    end

    def self.transition(job, to:)
      job.send(event_for(to)) if may_transition?(job, to: to)
    end

  end
end
