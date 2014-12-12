module Asyncapi::Client
  module V1
    class JobsController < Asyncapi::Client.parent_controller
      respond_to :json

      def index
        jobs = Job.all
        paginate json: jobs
      end

      def update
        job = Job.find_by(id: params[:id], secret: params[:job][:secret])
        if job
          job.assign_attributes(job_params)
          if job.status_changed? && job.save
            JobStatusWorker.perform_async(job.id)
          else
            job.save
          end
          respond_with job
        else
          render nothing: true, status: 403
        end
      end

      protected

      def job_params
        params.require(:job).permit(:status, :message)
      end

    end
  end
end
