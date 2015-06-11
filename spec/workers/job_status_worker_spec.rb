require "spec_helper"

module Asyncapi::Client
  describe JobStatusWorker, "#perform" do

    described_class::STATUS_CALLBACK_MAP.each do |status, attr_name|
      it "executes #{attr_name} callback class" do
        callback_class_name = attr_name.to_s.classify
        job = build_stubbed(
          :asyncapi_client_job,
          attr_name => callback_class_name,
          status: status,
        )

        allow(Job).to receive(:find).with(job.id).and_return(job)
        expect(callback_class_name.constantize).to receive(:call).with(job.id)

        described_class.new.perform(job.id)
      end
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
