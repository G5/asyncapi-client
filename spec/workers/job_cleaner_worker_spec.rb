require 'spec_helper'

module Asyncapi
  module Client
    describe JobCleanerWorker do

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

        context "when the remote job info is missing " do
          let(:logger_class){ class_double("G5::Logger::Log") }

          before do
            allow(Job).to receive(:find_by).with(id: job.id).and_return(job)
            allow(job).to receive(:destroy)
          end

          context 'when the job is missing the server_job_url' do
            let(:job) do
              build_stubbed(:asyncapi_client_job, {
                server_job_url: nil,
                secret: "sekret",
                headers: { AUTHORIZATION: "Bearer xyz" }
              })
            end

            it 'raise the error' do
              expect { described_class.new.perform(job.id) }.to raise_error(/Not enough info to delete expired remote job: server_job_url is invalid/)
            end
          end

          context 'when the job is missing the secret' do
            let(:job) do
              build_stubbed(:asyncapi_client_job, {
                server_job_url: "https://foo.com/job/feeds",
                secret: nil,
                headers: { AUTHORIZATION: "Bearer xyz" }
              })
            end

            it 'raise the error' do
              expect { described_class.new.perform(job.id) }.to raise_error(/Not enough info to delete expired remote job: secret is not present/)
            end
          end

          context 'when the job is missing the authorization headers' do
            let(:job) do
              build_stubbed(:asyncapi_client_job, {
                server_job_url: "https://foo.com/job/feeds",
                secret: "foo-secret",
                headers: { NO_AUTHORIZATION: "Bearer xyz" }
              })
            end

            it 'raise with the error' do
              expect { described_class.new.perform(job.id) }.to raise_error(/Not enough info to delete expired remote job: authorization headers are not present/)
            end
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
