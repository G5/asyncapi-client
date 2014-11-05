require "spec_helper"

module Asyncapi::Client
  describe JobStatusWorker, "#perform" do

    it "executes the appropriate callback class" do
      job = build_stubbed(
        :asyncapi_client_job,
        on_queue: "OnQueue",
        on_success: "OnSuccess",
        status: :success,
      )

      allow(Job).to receive(:find).with(job.id).and_return(job)
      expect(OnSuccess).to receive(:call).with(job.id)

      described_class.new.perform(job.id)
    end

    context "status callback is not defined" do
      it "does nothing" do
        job = build_stubbed(:asyncapi_client_job, status: :error)

        allow(Job).to receive(:find).with(job.id).and_return(job)

        expect { described_class.new.perform(job.id) }.to_not raise_error
      end
    end

    context "there is no status" do
      it "does nothing" do
        job = build_stubbed(:asyncapi_client_job, status: nil)
        allow(Job).to receive(:find).with(job.id).and_return(job)
        expect { described_class.new.perform(job.id) }.to_not raise_error
      end
    end

  end
end
