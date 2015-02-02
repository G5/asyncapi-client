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

    describe ".expired" do
      it "returns jobs whose expired_at times are in the past" do
        job_1 = create(:asyncapi_client_job, expired_at: 1.minute.from_now)
        job_2 = create(:asyncapi_client_job, expired_at: 1.minute.ago)
        job_3 = create(:asyncapi_client_job, expired_at: 1.minute.from_now)

        expect(described_class.expired.pluck(:id)).
          to match_array([job_2.id])
      end
    end

    describe "#expired_at" do
      let!(:old_value) { Asyncapi::Client.expiry_threshold }
      before { Timecop.freeze }
      after { Asyncapi::Client.expiry_threshold = old_value }

      it "is set to the Asyncapi::Client.expiry_threshold" do
        Asyncapi::Client.expiry_threshold = 12.days
        job = create(:asyncapi_client_job)
        expect(job.expired_at).to eq 12.days.from_now
      end

      it "honors if the attribute has already been set" do
        job = create(:asyncapi_client_job, expired_at: 2.days.from_now)
        expect(job.expired_at).to eq 2.days.from_now
      end
    end

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
          on_queue: OnQueue,
          on_success: OnSuccess,
          on_error: OnError,
          follow_up: follow_up,
          time_out: time_out,
          callback_params: callback_params,
        }
      end
      let(:follow_up) { 5.minutes }
      let(:time_out) { 30.minutes }
      let(:server_url)  { "http://server_url.com" }
      let(:callback_params) { {callback: "params"} }

      it "creates a job, delegates it to a JobPostWorker, and runs a cleanup job" do
        post

        job = described_class.last

        expect(JobPostWorker).to have_enqueued_job(job.id, server_url)
        expect(CleanerWorker).to have_enqueued_job

        expect(job.follow_up_at.to_i).to eq follow_up.from_now.to_i
        expect(job.time_out_at.to_i).to eq time_out.from_now.to_i
        expect(job.on_queue).to eq "OnQueue"
        expect(job.on_success).to eq "OnSuccess"
        expect(job.on_error).to eq "OnError"
        expect(job.callback_params).to eq({callback: "params"})
        expect(job.body).to eq '{"json": "object"}'
        expect(job.headers).to eq({"CONTENT_TYPE" => "application/json"})
      end

    end

    [:on_queue, :on_error, :on_success].each do |attr|
      it "can set `#{attr}` using a class name" do
        job = build_stubbed(:asyncapi_client_job, attr => OnError)
        expect(job.send(attr)).to eq "OnError"
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

  describe "#secret" do
    it "always generates a secret" do
      job = build(:asyncapi_client_job)
      expect(job.secret).to be_present
      initial_secret = job.secret
      job.save
      expect(job.reload.secret).to eq initial_secret
    end
  end

end
