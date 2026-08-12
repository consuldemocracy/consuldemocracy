require "rails_helper"

describe Budgets::SensemakingController do
  def create_publishable_job_with_output(attributes = {})
    job = create(:sensemaker_job, :publishable, attributes)
    output_path = job.artefacts.default_output_path
    FileUtils.mkdir_p(File.dirname(output_path))
    File.write(output_path, "<html><body>Test Report</body></html>")
    job.update!(published: true)
    job
  end

  after do
    Sensemaker::Job.find_each do |job|
      if job.artefacts.default_output_path && File.exist?(job.artefacts.default_output_path)
        FileUtils.rm_f(job.artefacts.default_output_path)
      end
    end
  end

  describe "GET #show" do
    let(:budget) { create(:budget, :finished, sensemaking_enabled: true) }
    let!(:published_job) do
      create_publishable_job_with_output(analysable_type: "Budget", analysable_id: budget.id)
    end
    let!(:unpublished_job) do
      job = create(:sensemaker_job, :publishable, analysable_type: "Budget", analysable_id: budget.id,
                                                  published: false)
      output_path = job.artefacts.default_output_path
      FileUtils.mkdir_p(File.dirname(output_path))
      File.write(output_path, "<html><body>Test Report</body></html>")
      job
    end

    before do
      Setting["llm.provider"] = "OpenAI"
      Setting["llm.model"] = "gpt-4o"
      Setting["llm.use_sensemaker"] = true
    end

    it "returns published jobs for guests" do
      get :show, params: { budget_id: budget.id }

      expect(response).to have_http_status(:ok)
      jobs = controller.instance_variable_get(:@sensemaker_jobs)
      expect(jobs).to include(published_job)
      expect(jobs).not_to include(unpublished_job)
    end

    context "when the current user is an administrator", :admin do
      it "returns unpublished publishable jobs" do
        get :show, params: { budget_id: budget.id }

        expect(response).to have_http_status(:ok)
        jobs = controller.instance_variable_get(:@sensemaker_jobs)
        expect(jobs).to include(published_job)
        expect(jobs).to include(unpublished_job)
      end
    end
  end
end
