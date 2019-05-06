require 'spec_helper'

module Asyncapi
  module Client
    describe CleanerWorker do

      it "does not retry" do
        expect(described_class.sidekiq_options_hash['retry']).to be false
      end

      it "enqueues a cleanup background job per expired job" do
        deleted_job_1 = create(:asyncapi_client_job, expired_at: 1.minute.ago)
        kept_job = create(:asyncapi_client_job, expired_at: 1.minute.from_now)
        deleted_job_2 = create(:asyncapi_client_job, expired_at: 1.second.ago)

        described_class.new.perform

        expect(JobCleanerWorker).to have_enqueued_sidekiq_job(deleted_job_1.id)
        expect(JobCleanerWorker).to_not have_enqueued_sidekiq_job(kept_job.id)
        expect(JobCleanerWorker).to have_enqueued_sidekiq_job(deleted_job_2.id)
      end

    end
  end
end
