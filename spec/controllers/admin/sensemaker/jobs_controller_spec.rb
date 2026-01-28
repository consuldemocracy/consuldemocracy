require "rails_helper"

describe Admin::Sensemaker::JobsController do
  let(:admin) { create(:administrator).user }
  let(:user) { create(:user) }
  let(:debate) { create(:debate) }
  let(:proposal) { create(:proposal) }
  let(:sensemaker_job) do
    create(:sensemaker_job, user: admin, analysable_type: "Debate", analysable_id: debate.id)
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

  describe "GET #download" do
    let(:job) { sensemaker_job }

    context "when artefact param is provided and valid" do
      let(:data_folder) { Sensemaker::Paths.sensemaker_data_folder.to_s }
      let(:basename) { "artifact-#{SecureRandom.hex}.json" }
      let(:tmp_file) { File.join(data_folder, basename) }

      before do
        FileUtils.mkdir_p(File.dirname(tmp_file))
        File.write(tmp_file, "{}")
        allow_any_instance_of(Sensemaker::Job).to receive(:output_artifact_paths)
          .and_return([tmp_file])
      end

      after do
        FileUtils.rm_f(tmp_file)
      end

      it "sends the requested artefact file" do
        get :download, params: { id: job.id, artefact: basename }

        expect(response).to have_http_status(:ok)
        expect(response.header["Content-Disposition"]).to include(basename)
      end
    end

    context "when artefact param is invalid" do
      it "redirects to show with alert" do
        allow_any_instance_of(Sensemaker::Job).to receive(:output_artifact_paths)
          .and_return([])

        get :download, params: { id: job.id, artefact: "nonexistent.json" }

        expect(response).to redirect_to(admin_sensemaker_job_path(job))
        expect(flash[:alert]).to be_present
      end
    end

    context "when no artefact param and persisted_output exists" do
      let(:tmp_file) { Rails.root.join("tmp", "persisted-#{SecureRandom.hex}.html").to_s }

      before do
        FileUtils.mkdir_p(File.dirname(tmp_file))
        File.write(tmp_file, "<html></html>")
        job.update!(persisted_output: tmp_file)
      end

      after do
        FileUtils.rm_f(tmp_file)
      end

      it "sends the persisted_output file" do
        get :download, params: { id: job.id }

        expect(response).to have_http_status(:ok)
        expect(response.header["Content-Disposition"]).to include(File.basename(tmp_file))
      end
    end

    context "when no artefact param and no persisted_output" do
      it "redirects to index with not found alert" do
        allow_any_instance_of(Sensemaker::Job).to receive(:persisted_output).and_return(nil)

        get :download, params: { id: job.id }

        expect(response).to redirect_to(admin_sensemaker_jobs_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "GET #new" do
    it "returns successful response" do
      get :new

      expect(response).to have_http_status(:ok)
    end

    context "with target_type and target_id params" do
      it "processes target parameters successfully" do
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
          analysable_type: "Debate",
          analysable_id: debate.id,
          script: "categorization_runner.ts",
          additional_context: "Test context"
        }
      }
    end

    it "creates a new sensemaker job and runs it" do
      allow_any_instance_of(Sensemaker::JobRunner).to receive(:check_dependencies?).and_return(false)
      allow_any_instance_of(Sensemaker::JobRunner).to receive(:prepare_input_data)
      allow_any_instance_of(Sensemaker::JobRunner).to receive(:execute_script).and_return("")

      expect do
        post :create, params: valid_params
      end.to change(Sensemaker::Job, :count).by(1)

      job = Sensemaker::Job.last
      expect(job.user).to eq(admin)
      expect(job.analysable_type).to eq("Debate")
      expect(job.analysable_id).to eq(debate.id)
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
          analysable_type: "Debate",
          analysable_id: debate.id,
          script: "categorization_runner.ts"
        }
      }
    end

    it "renders preview for valid analysable" do
      get :preview, params: valid_params, format: :html

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Additional context")
      expect(response.body).to include("Input CSV")
      expect(response.body).to include("comment-id,comment_text")
    end

    it "handles missing analysable" do
      get :preview, params: { sensemaker_job: { analysable_type: "Debate", analysable_id: 999 }}

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("Error: Target not found")
    end

    it "responds with CSV format" do
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

  describe "PATCH #publish" do
    let(:successful_job) do
      output_path = Rails.root.join("tmp", "test-report-#{SecureRandom.hex}.html").to_s
      FileUtils.mkdir_p(File.dirname(output_path))
      File.write(output_path, "<html><body>Test Report</body></html>")

      create(:sensemaker_job,
             user: admin,
             analysable_type: "Debate",
             analysable_id: debate.id,
             script: "single-html-build.js",
             started_at: 1.hour.ago,
             finished_at: Time.current,
             error: nil,
             published: false,
             persisted_output: output_path)
    end

    after do
      if successful_job&.persisted_output.present?
        FileUtils.rm_f(successful_job.persisted_output)
      end
    end

    context "when job is eligible for publishing" do
      it "publishes the job" do
        patch :publish, params: { id: successful_job.id }

        successful_job.reload
        expect(successful_job.published).to be true
      end

      it "redirects to job show page with success notice" do
        patch :publish, params: { id: successful_job.id }

        expect(response).to redirect_to(admin_sensemaker_job_path(successful_job))
        expect(flash[:notice]).to be_present
      end
    end

    context "when job is not finished" do
      let(:unfinished_job) do
        create(:sensemaker_job,
               user: admin,
               analysable_type: "Debate",
               analysable_id: debate.id,
               script: "single-html-build.js",
               started_at: Time.current,
               finished_at: nil,
               error: nil,
               published: false)
      end

      it "does not publish the job" do
        patch :publish, params: { id: unfinished_job.id }

        unfinished_job.reload
        expect(unfinished_job.published).to be false
      end

      it "redirects with alert message" do
        patch :publish, params: { id: unfinished_job.id }

        expect(response).to redirect_to(admin_sensemaker_job_path(unfinished_job))
        expect(flash[:alert]).to be_present
      end
    end

    context "when job has error" do
      let(:errored_job) do
        create(:sensemaker_job,
               user: admin,
               analysable_type: "Debate",
               analysable_id: debate.id,
               script: "single-html-build.js",
               started_at: 1.hour.ago,
               finished_at: Time.current,
               error: "Some error occurred",
               published: false)
      end

      it "does not publish the job" do
        patch :publish, params: { id: errored_job.id }

        errored_job.reload
        expect(errored_job.published).to be false
      end

      it "redirects with alert message" do
        patch :publish, params: { id: errored_job.id }

        expect(response).to redirect_to(admin_sensemaker_job_path(errored_job))
        expect(flash[:alert]).to be_present
      end
    end

    context "when job has no output" do
      let(:job_without_output) do
        create(:sensemaker_job,
               user: admin,
               analysable_type: "Debate",
               analysable_id: debate.id,
               script: "single-html-build.js",
               started_at: 1.hour.ago,
               finished_at: Time.current,
               error: nil,
               published: false,
               persisted_output: nil)
      end

      it "does not publish the job" do
        patch :publish, params: { id: job_without_output.id }

        job_without_output.reload
        expect(job_without_output.published).to be false
      end

      it "redirects with alert message" do
        patch :publish, params: { id: job_without_output.id }

        expect(response).to redirect_to(admin_sensemaker_job_path(job_without_output))
        expect(flash[:alert]).to be_present
      end
    end

    context "when job script is not publishable" do
      let(:non_publishable_job) do
        output_path = Rails.root.join("tmp", "test-report-#{SecureRandom.hex}.html").to_s
        FileUtils.mkdir_p(File.dirname(output_path))
        File.write(output_path, "<html><body>Test Report</body></html>")

        create(:sensemaker_job,
               user: admin,
               analysable_type: "Debate",
               analysable_id: debate.id,
               script: "categorization_runner.ts",
               started_at: 1.hour.ago,
               finished_at: Time.current,
               error: nil,
               published: false,
               persisted_output: output_path)
      end

      after do
        if non_publishable_job&.persisted_output.present?
          FileUtils.rm_f(non_publishable_job.persisted_output)
        end
      end

      it "does not publish the job" do
        patch :publish, params: { id: non_publishable_job.id }

        non_publishable_job.reload
        expect(non_publishable_job.published).to be false
      end

      it "redirects with alert message" do
        patch :publish, params: { id: non_publishable_job.id }

        expect(response).to redirect_to(admin_sensemaker_job_path(non_publishable_job))
        expect(flash[:alert]).to be_present
      end
    end

    context "when job script is runner.ts" do
      let(:runner_job) do
        data_folder = Sensemaker::Paths.sensemaker_data_folder
        base_path = File.join(data_folder, "output-#{SecureRandom.hex}")
        output_files = [
          "#{base_path}-summary.json",
          "#{base_path}-summary.html",
          "#{base_path}-summary.md",
          "#{base_path}-summaryAndSource.csv"
        ]

        FileUtils.mkdir_p(File.dirname(base_path))
        output_files.each { |file| File.write(file, "test content") }

        create(:sensemaker_job,
               user: admin,
               analysable_type: "Debate",
               analysable_id: debate.id,
               script: "runner.ts",
               started_at: 1.hour.ago,
               finished_at: Time.current,
               error: nil,
               published: false,
               persisted_output: base_path)
      end

      after do
        if runner_job&.persisted_output.present?
          base_path = runner_job.persisted_output
          [
            "#{base_path}-summary.json",
            "#{base_path}-summary.html",
            "#{base_path}-summary.md",
            "#{base_path}-summaryAndSource.csv"
          ].each { |file| FileUtils.rm_f(file) }
        end
      end

      it "publishes the job" do
        patch :publish, params: { id: runner_job.id }

        runner_job.reload
        expect(runner_job.published).to be true
      end

      it "redirects to job show page with success notice" do
        patch :publish, params: { id: runner_job.id }

        expect(response).to redirect_to(admin_sensemaker_job_path(runner_job))
        expect(flash[:notice]).to be_present
      end
    end
  end

  describe "PATCH #unpublish" do
    let(:published_job) do
      output_path = Rails.root.join("tmp", "test-report-#{SecureRandom.hex}.html").to_s
      FileUtils.mkdir_p(File.dirname(output_path))
      File.write(output_path, "<html><body>Test Report</body></html>")

      create(:sensemaker_job,
             user: admin,
             analysable_type: "Debate",
             analysable_id: debate.id,
             script: "single-html-build.js",
             started_at: 1.hour.ago,
             finished_at: Time.current,
             error: nil,
             published: true,
             persisted_output: output_path)
    end

    after do
      if published_job&.persisted_output.present?
        FileUtils.rm_f(published_job.persisted_output)
      end
    end

    it "unpublishes the job" do
      patch :unpublish, params: { id: published_job.id }

      published_job.reload
      expect(published_job.published).to be false
    end

    it "redirects to job show page with success notice" do
      patch :unpublish, params: { id: published_job.id }

      expect(response).to redirect_to(admin_sensemaker_job_path(published_job))
      expect(flash[:notice]).to be_present
    end
  end

  describe "private methods" do
    describe "#sensemaker_job_params" do
      it "permits required parameters" do
        params = ActionController::Parameters.new({
          sensemaker_job: {
            analysable_type: "Debate",
            analysable_id: "123",
            script: "test.ts",
            additional_context: "context"
          }
        })

        controller.params = params
        permitted = controller.send(:sensemaker_job_params)

        expect(permitted.keys).to include("analysable_type", "analysable_id", "script",
                                          "additional_context")
      end
    end
  end
end
