require "spec_helper"

module Asyncapi::Client
  describe JobPostWorker, "#perform" do

    let(:job) do
      build_stubbed(:asyncapi_client_job, {
        body: body,
        headers: headers,
      })
    end
    let(:body) { {my: "body"}.to_json }
    let(:headers) { {my: "head"} }
    let(:server_url) { "server.url" }
    let(:server_params) do
      { job: { callback_url: job.url, params: body, secret: job.secret } }
    end

    before do
      allow(Job).to receive(:find).with(job.id).and_return(job)
      allow(Typhoeus).to receive(:post).
        with(server_url, body: server_params, headers: headers).
        and_return(server_response)
    end

    context "successful response from server" do
      context "job is queued and successfully updated" do
        let(:server_response) do
          double(
            success?: true,
            body: { job: {url: "server/job/99", status: "queued"} }.to_json,
          )
        end

        it "enqueues the JobStatusWorker" do
          expect(job).to receive(:assign_attributes).
            with(server_job_url: "server/job/99").
            and_return(true)
          expect(job).to receive(:enqueue)
          expect(job).to receive(:save!).and_return(true)
          expect(JobStatusWorker).to receive(:perform_async).with(job.id)
          described_class.new.perform(job.id, server_url)
        end
      end
    end

    context "unsuccessful response from server" do
      let(:server_response) { double(success?: false, body: "response body") }

      context "successfully updated job with error" do
        it "updates the job with error and the response body" do
          expect(job).to receive(:update_attributes).
            with(status: :error, message: "response body").
            and_return(true)
          expect(JobStatusWorker).to receive(:perform_async).with(job.id)
          described_class.new.perform(job.id, server_url)
        end
      end

      context "unsuccessfuly updated job with error" do
        it "does nothing" do
          expect(job).to receive(:update_attributes).
            with(status: :error, message: "response body").
            and_return(false)
          expect(JobStatusWorker).to_not receive(:perform_async).with(job.id)
          described_class.new.perform(job.id, server_url)
        end
      end
    end

  end
end
