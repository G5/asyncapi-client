require "spec_helper"

module Asyncapi::Client
  describe Job do

    subject(:job) { described_class.create(params) }
    let(:params) do
      {
        server_job_url: "http://server_job_url.com",
        status: "queued",
        message: "message",
        follow_up_at: DateTime.new(2014,10,30,12,30),
        time_out_at: DateTime.new(2014,10,30,12,50),
        on_queue: "QueuedJobWorker",
        on_success: "SuccessfulJobWorker",
        on_error: "FailedJobWorker",
        body: '{"json": "object"}',
        headers: {"CONTENT_TYPE" => "application/json"}
      }
    end

    its(:server_job_url) { is_expected.to eq "http://server_job_url.com" }
    its(:status) { is_expected.to eq "queued" }
    it { is_expected.to be_queued }
    it { is_expected.not_to be_success }
    it { is_expected.not_to be_error }
    its(:message) { is_expected.to eq "message" }
    its(:follow_up_at) { is_expected.to eq DateTime.new(2014, 10, 30, 12, 30) }
    its(:time_out_at) { is_expected.to eq DateTime.new(2014, 10, 30, 12, 50) }
    its(:on_queue) { is_expected.to eq "QueuedJobWorker" }
    its(:on_success) { is_expected.to eq "SuccessfulJobWorker" }
    its(:on_error) { is_expected.to eq "FailedJobWorker" }
    its(:headers) { is_expected.to eq({"CONTENT_TYPE" => "application/json"}) }

    describe "#body=" do
      context "given json" do
        it "remains as json" do
          job = build_stubbed(:asyncapi_client_job, body: %Q({"json": "thing"}))
          expect(JSON.parse(job.body).with_indifferent_access[:json]).
            to eq "thing"
        end
      end

      context "given params" do
        it "is converted to json" do
          job = build_stubbed(:asyncapi_client_job, body: {ruby: "hash"})
          expect(job.body).to eq %Q({"ruby":"hash"})
        end
      end
    end

    describe ".post" do
      before { Timecop.freeze }
      subject(:post) { described_class.post(server_url, post_params) }

      let(:post_params) do
        {
          headers: {"CONTENT_TYPE" => "application/json"},
          body: '{"json": "object"}',
          on_queue: "QueuedJobWorker",
          on_success: "SuccessfulJobWorker",
          on_error: "FailedJobWorker",
          follow_up: follow_up,
          time_out: time_out,
          callback_params: callback_params,
        }
      end
      let(:follow_up) { 5.minutes }
      let(:time_out) { 30.minutes }
      let(:server_url)  { "http://server_url.com" }
      let(:callback_params) { {callback: "params"} }

      it "creates a job and delegates it to a JobPostWorker" do
        post

        job = described_class.last

        expect(JobPostWorker).to have_enqueued_job(job.id, server_url)

        expect(job.follow_up_at.to_i).to eq follow_up.from_now.to_i
        expect(job.time_out_at.to_i).to eq time_out.from_now.to_i
        expect(job.on_queue).to eq "QueuedJobWorker"
        expect(job.on_success).to eq "SuccessfulJobWorker"
        expect(job.on_error).to eq "FailedJobWorker"
        expect(job.callback_params).to eq({callback: "params"})
        expect(job.body).to eq '{"json": "object"}'
        expect(job.headers).to eq({"CONTENT_TYPE" => "application/json"})
      end

    end
  end

  describe "#url" do
    let(:job) { build_stubbed(:asyncapi_client_job) }
    subject(:url) { job.url }
    it do
      expected_url = "http://test.com/asyncapi/client/v1/jobs/#{job.id}"
      is_expected.to include(expected_url)
    end
  end

  describe "#headers" do
    it "allows retrieval of headers" do
      job = create(:asyncapi_client_job, headers: {"CONTENT-TYPE" => "wow"})
      expect(job.reload.headers).to match({"CONTENT-TYPE" => "wow"})
    end
  end

end
