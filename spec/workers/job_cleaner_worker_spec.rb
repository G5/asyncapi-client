require 'spec_helper'

module Asyncapi
  module Client
    describe JobCleanerWorker do

      it "does not retry" do
        expect(described_class.sidekiq_options_hash['retry']).to be false
      end

      describe "#perform" do
        context "job exists" do
          let(:job) do
            build_stubbed(:asyncapi_client_job, {
              server_job_url: "https://server.com/123",
              secret: "sekret",
              headers: {
                AUTHORIZATION: "Bearer xyz",
              }
            })
          end

          let(:response) { double(:typhoeus_response, success?: true) }

          before do
            allow(Job).to receive(:find_by).with(id: job.id).and_return(job)
          end

          it "deletes the remote job and deletes the given job" do
            expect(Typhoeus).to receive(:delete).with("https://server.com/123", {
              params: { secret: "sekret" },
              headers: {AUTHORIZATION: "Bearer xyz"},
            }).and_return(response)
            expect(job).to receive(:destroy)

            described_class.new.perform(job.id)
          end
        end

        context "job does not exist" do
          it "does nothing" do
            expect{ described_class.new.perform(12312) }.to_not raise_error
          end
        end
      end

    end
  end
end
