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

    describe "delegated attrs" do
      [:callback_params, :headers].each do |attr|
        describe "#{attr}" do
          let(:job) do
            build_stubbed(:asyncapi_client_job, attr => {attr => "val"})
          end

          it "accesses the job's #{attr}" do
            runner = runner_class.new(job.id)
            expect(runner.send(attr)).to eq({attr => "val"})
          end
        end
      end

      [:body, :message].each do |attr|
        describe "#{attr}" do
          let(:job) do
            build_stubbed(:asyncapi_client_job, attr => "value for #{attr}")
          end

          it "accesses the job's #{attr}" do
            runner = runner_class.new(job.id)
            expect(runner.send(attr)).to eq "value for #{attr}"
          end
        end
      end

      describe "response_code" do
        let(:job) { build_stubbed(:asyncapi_client_job, response_code: 200) }
        it "accesses the job's response_code" do
          runner = runner_class.new(job.id)
          expect(runner.response_code).to eq 200
        end
      end
    end

  end
end
