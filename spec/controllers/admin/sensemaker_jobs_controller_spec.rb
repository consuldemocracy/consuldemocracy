require "rails_helper"

describe Admin::SensemakerJobsController do
  let(:admin) { create(:administrator).user }
  let(:user) { create(:user) }
  let(:debate) { create(:debate) }
  let(:proposal) { create(:proposal) }
  let(:sensemaker_job) do
    create(:sensemaker_job, user: admin, commentable_type: "Debate", commentable_id: debate.id)
  end

  before { sign_in(admin) }

  describe "GET #index" do
    it "returns successful response" do
      get :index

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #show" do
    it "returns successful response" do
      get :show, params: { id: sensemaker_job.id }

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #new" do
    it "returns successful response" do
      get :new

      expect(response).to have_http_status(:ok)
    end

    context "with target_type and target_id params" do
      it "processes target parameters successfully" do
        allow(Sensemaker::JobRunner).to receive(:compile_context).with(debate).and_return("Test context")

        get :new, params: { target_type: "Debate", target_id: debate.id }

        expect(response).to have_http_status(:ok)
      end
    end

    context "with search query" do
      it "handles Legislation::Process search" do
        process = create(:legislation_process)
        create(:legislation_proposal, process: process)
        create(:legislation_question, process: process)

        get :new, params: { query: process.title, query_type: "Legislation::Process" }

        expect(response).to have_http_status(:ok)
      end

      it "handles other model type search" do
        get :new, params: { query: "test", query_type: "Debate" }

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST #create" do
    let(:valid_params) do
      {
        sensemaker_job: {
          commentable_type: "Debate",
          commentable_id: debate.id,
          script: "categorization_runner.ts",
          additional_context: "Test context"
        }
      }
    end

    it "creates a new sensemaker job and runs it" do
      # Mock external dependencies to allow the real workflow to run
      allow_any_instance_of(Sensemaker::JobRunner).to receive(:check_dependencies?).and_return(false)
      allow_any_instance_of(Sensemaker::JobRunner).to receive(:prepare_input_data)
      allow_any_instance_of(Sensemaker::JobRunner).to receive(:execute_script).and_return("")
      allow_any_instance_of(Sensemaker::JobRunner).to receive(:process_output)

      expect do
        post :create, params: valid_params
      end.to change(Sensemaker::Job, :count).by(1)

      job = Sensemaker::Job.last
      expect(job.user).to eq(admin)
      expect(job.commentable).to eq(debate)
      expect(job.script).to eq("categorization_runner.ts")
      expect(job.started_at).to be_present
    end

    it "redirects to index with success notice" do
      allow(Sensemaker::JobRunner).to receive(:new).and_return(double(run_synchronously: true))

      post :create, params: valid_params

      expect(response).to redirect_to(admin_sensemaker_jobs_path)
    end
  end

  describe "GET #preview" do
    let(:valid_params) do
      {
        sensemaker_job: {
          commentable_type: "Debate",
          commentable_id: debate.id,
          script: "categorization_runner.ts"
        }
      }
    end

    it "renders preview for valid commentable" do
      allow(Sensemaker::JobRunner).to receive(:compile_context).and_return("Context")
      allow(Sensemaker::CsvExporter).to receive(:new).and_return(double(export_to_string: "CSV data"))

      get :preview, params: valid_params, format: :html

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Context")
      expect(response.body).to include("CSV data")
    end

    it "handles missing commentable" do
      get :preview, params: { sensemaker_job: { commentable_type: "Debate", commentable_id: 999 }}

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("Error: Target not found")
    end

    it "responds with CSV format" do
      allow(Sensemaker::JobRunner).to receive(:compile_context).and_return("Context")
      allow(Sensemaker::CsvExporter).to receive(:new).and_return(double(export_to_string: "CSV data"))

      get :preview, params: valid_params, format: :csv

      expect(response.content_type).to include("text/csv")
    end
  end

  describe "DELETE #destroy" do
    it "destroys the sensemaker job" do
      delete :destroy, params: { id: sensemaker_job.id }

      expect { sensemaker_job.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "redirects to index with success notice" do
      delete :destroy, params: { id: sensemaker_job.id }

      expect(response).to redirect_to(admin_sensemaker_jobs_path)
      expect(flash[:notice]).to be_present
    end
  end

  describe "POST #cancel" do
    it "destroys all delayed jobs and cancels running sensemaker jobs" do
      expect(Delayed::Job).to receive(:where)
        .with(queue: "sensemaker").and_return(double(destroy_all: true))

      running_jobs_double = double("running_jobs")
      expect(Sensemaker::Job).to receive(:running).and_return(running_jobs_double)
      expect(running_jobs_double).to receive(:all).and_return([sensemaker_job])
      expect(sensemaker_job).to receive(:cancel!)

      post :cancel

      expect(response).to redirect_to(admin_sensemaker_jobs_path)
      expect(flash[:notice]).to be_present
    end
  end

  describe "private methods" do
    describe "#sensemaker_job_params" do
      it "permits required parameters" do
        params = ActionController::Parameters.new({
          sensemaker_job: {
            commentable_type: "Debate",
            commentable_id: "123",
            script: "test.ts",
            additional_context: "context"
          }
        })

        controller.params = params
        permitted = controller.send(:sensemaker_job_params)

        expect(permitted.keys).to include("commentable_type", "commentable_id", "script",
                                          "additional_context")
      end
    end
  end
end
