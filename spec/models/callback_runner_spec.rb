require "spec_helper"

module Asyncapi::Client
  describe CallbackRunner do

    let(:job) { build_stubbed(:asyncapi_client_job) }
    let(:runner_class) do
      Class.new(CallbackRunner) do
        def call
          "hi #{job.id}"
        end
      end
    end

    before do
      allow(Job).to receive(:find).with(job.id).and_return(job)
    end

    describe ".call" do
      it "initializes the runner and executes #call" do
        result = runner_class.call(job.id)
        expect(result).to eq "hi #{job.id}"
      end
    end

    describe "initialization" do
      it "accepts a job id" do
        runner = runner_class.new(job.id)
        expect(runner.job_id).to eq job.id
      end
    end

    describe "#job" do
      it "returns the job with the job_id" do
        runner = runner_class.new(job.id)
        expect(runner.job).to eq job
      end
    end

    [:callback_params, :body, :headers, :message].each do |attr|
      describe "#callback_params" do
        let(:job) do
          build_stubbed(:asyncapi_client_job, attr => "value for #{attr}")
        end

        it "accesses the job's #{attr}" do
          runner = runner_class.new(job.id)
          expect(runner.send(attr)).to eq "value for #{attr}"
        end
      end
    end

  end
end
