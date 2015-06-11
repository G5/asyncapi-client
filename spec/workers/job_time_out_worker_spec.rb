require "spec_helper"

module Asyncapi::Client
  describe JobTimeOutWorker do

    it "does not retry" do
      expect(described_class.sidekiq_options_hash["retry"]).to be false
    end

    describe "#perform" do
      let!(:job_1_not_timed_out) do
        create(:asyncapi_client_job, time_out_at: 30.minutes.from_now)
      end
      let!(:job_2_timed_out) do
        create(:asyncapi_client_job, time_out_at: 25.minutes.from_now)
      end
      let!(:job_3_successful) do
        create(:asyncapi_client_job, {
          time_out_at: 25.minutes.from_now,
          status: "success",
        })
      end
      let!(:job_4_never_time_out) { create(:asyncapi_client_job) }

      it "times out jobs that should be timed out and runs the JobStatusWorker for them" do
        Timecop.travel 26.minutes.from_now

        described_class.new.perform

        expect(job_1_not_timed_out.reload.status).to_not eq "timed_out"
        expect(job_2_timed_out.reload.status).to eq "timed_out"
        expect(job_3_successful.reload.status).to eq "success"
        expect(job_4_never_time_out.reload.status).to_not eq "timed_out"
        expect(JobStatusWorker).to have_enqueued_job(job_2_timed_out.id)
      end
    end

  end
end
