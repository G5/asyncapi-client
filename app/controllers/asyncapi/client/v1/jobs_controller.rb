module Asyncapi::Client
  module V1
    class JobsController < Asyncapi::Client.parent_controller
      include Rails::Pagination

      def index
        jobs = Job.all
        paginate json: jobs
      end

      def update
        if job = Job.find_by(id: params[:id], secret: params[:job][:secret])
          UpdateJob.execute(job: job, params: job_params)
          render json: job
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
