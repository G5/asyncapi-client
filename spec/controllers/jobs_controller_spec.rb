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

        context "secret is invalid" do
          let(:job_params) do
            {
              status: "success",
              message: "Haxxors",
              secret: "lala",
            }
          end

          it "does nothing" do
            expect(job).to_not receive(:save)
            put :update, params.merge(id: job.id, format: :json)
            job.reload
            expect(job.status).to eq "queued"
            expect(response.status).to eq 403
          end
        end

        context "correct secret" do
          let(:job_params) do
            {
              status: "success",
              message: "Great success",
              secret: job.secret,
            }
          end

          it "updates the job" do
            expected_job_params = job_params.slice(:status, :message)
            expect(UpdateJob).to receive(:execute).
              with(job: job, params: expected_job_params)

            put :update, params.merge(id: job.id, format: :json)
          end
        end
      end

    end
  end
end
