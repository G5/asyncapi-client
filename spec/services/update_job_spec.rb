require "spec_helper"

module Asyncapi::Client
  describe UpdateJob, ".execute" do

    context "from same state" do
      let(:job) { create(:asyncapi_client_job, status: "success") }

      it "does not perform status work but updates the message" do
        params = {
          status: "success",
          message: "Great success",
        }

        UpdateJob.execute(job: job, params: params)

        job.reload

        expect(job.message).to eq "Great success"
        expect(JobStatusWorker).to_not have_enqueued_job(job.id)
      end
    end

    context "from queued" do
      let(:job) { create(:asyncapi_client_job, status: "queued") }

      it "can mark it as success" do
        params = {
          status: "success",
          message: "Great success",
        }

        UpdateJob.execute(job: job, params: params)

        job.reload

        expect(job).to be_success
        expect(job.message).to eq "Great success"
        expect(JobStatusWorker).to have_enqueued_job(job.id)
      end

      it "can mark it as error" do
        params = {
          status: "error",
          message: "Failure there",
        }

        UpdateJob.execute(job: job, params: params)

        job.reload

        expect(job).to be_error
        expect(job.message).to eq "Failure there"
        expect(JobStatusWorker).to have_enqueued_job(job.id)
      end
    end

    context "from final state" do
      let(:job) do
        create(:asyncapi_client_job, status: "success", message: "Ok")
      end

      it "ignores changes" do
        params = {
          status: "error",
          message: "Bad",
        }

        UpdateJob.execute(job: job, params: params)

        job.reload

        expect(job).to be_success
        expect(job.message).to eq "Ok"
        expect(JobStatusWorker).to_not have_enqueued_job
      end
    end

  end
end
