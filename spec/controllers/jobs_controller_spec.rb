require "spec_helper"

module Asyncapi::Client
  module V1
    describe JobsController, type: :controller do

      routes { Engine.routes }

      describe "GET #index" do
        it "returns a paginated list of jobs" do
          job_1 = create(:asyncapi_client_job)
          job_2 = create(:asyncapi_client_job)
          get :index, per_page: 1, page: 2, format: :json
          json_response = indifferent_hash(response.body)
          expect(json_response.first[:id]).to eq job_2.id
        end
      end

      describe "PUT #update" do
        let(:job) { create(:asyncapi_client_job, status: :queued) }
        let(:params) { {job: job_params} }

        context "job status changes" do
          context "job is valid" do
            let(:job_params) { {status: "success", message: "Great success" } }
            it "performs JobStatusWorker" do
              expect(JobStatusWorker).to receive(:perform_async).with(job.id)
              put :update, params.merge(id: job.id, format: :json)
              job.reload
              expect(job.status).to eq "success"
              expect(job.message).to eq "Great success"
              expect(response).to be_successful
            end
          end

          context "job is invalid" do
            let(:job_params) { {message: "asd"} }
            it "does nothing" do
              # NOTE: assigning a value to an enum (status, in this case) that
              # isn't understood will raise ArgumentError. We must stub save to
              # test this
              allow(job).to receive(:save).and_return(false)
              expect(JobsController).to_not receive(:perform_async)
              put :update, params.merge(id: job.id, format: :json)
              job.reload
              expect(job.status).to eq "queued"
            end
          end
        end

        context "job status does not change" do
          let(:job_params) {{ status: job.status, message: "Something new" }}
          it "saves the changes only" do
            expect(JobStatusWorker).to_not receive(:perform_async)
            put :update, params.merge(id: job.id, format: :json)
            expect(job.reload.message).to eq "Something new"
          end
        end
      end

    end
  end
end
