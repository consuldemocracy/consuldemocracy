require "rails_helper"

describe Sensemaker::JobsController do
  include Rails.application.routes.url_helpers

  let(:user) { create(:user) }

  def create_publishable_job_with_output(attributes = {})
    job = create(:sensemaker_job, :publishable, attributes)
    output_path = job.default_output_path
    FileUtils.mkdir_p(File.dirname(output_path))
    File.write(output_path, "<html><body>Test Report</body></html>")
    job.update!(published: true)
    job
  end

  after do
    Sensemaker::Job.find_each do |job|
      if job.default_output_path && File.exist?(job.default_output_path)
        FileUtils.rm_f(job.default_output_path)
      end
    end
  end

  describe "GET #show" do
    let(:debate) { create(:debate) }
    let(:job) { create_publishable_job_with_output(analysable_type: "Debate", analysable_id: debate.id) }

    context "when job is unpublished" do
      before do
        job.update!(published: false)
      end

      it "returns 302 and redirects to root path" do
        get :show, params: { id: job.id }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when job exists and has output" do
      it "renders the report view page" do
        get :show, params: { id: job.id }

        expect(response).to have_http_status(:ok)
      end
    end

    context "when job exists but has no output" do
      before do
        FileUtils.rm_f(job.default_output_path)
      end

      it "returns 404" do
        get :show, params: { id: job.id }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET #index" do
    context "when resource_type and resource_id are provided" do
      context "for a Debate" do
        let(:debate) { create(:debate) }
        let!(:job1) do
          create_publishable_job_with_output(analysable_type: "Debate", analysable_id: debate.id,
                                             finished_at: 2.days.ago)
        end
        let!(:job2) do
          create_publishable_job_with_output(analysable_type: "Debate", analysable_id: debate.id,
                                             finished_at: 1.day.ago)
        end
        let!(:other_job) do
          create_publishable_job_with_output(analysable_type: "Debate", analysable_id: create(:debate).id)
        end

        it "returns published jobs for the resource ordered by finished_at desc" do
          get :index, params: { resource_type: "debates", resource_id: debate.id }

          expect(response).to have_http_status(:ok)
          jobs = controller.instance_variable_get(:@sensemaker_jobs)
          expect(jobs.to_a).to eq([job2, job1])
          expect(jobs).not_to include(other_job)
          expect(controller.instance_variable_get(:@parent_resource)).to be(nil)
        end
      end

      context "for a Proposal" do
        let(:proposal) { create(:proposal) }
        let!(:job) do
          create_publishable_job_with_output(analysable_type: "Proposal", analysable_id: proposal.id)
        end

        it "returns published jobs for the proposal" do
          get :index, params: { resource_type: "proposals", resource_id: proposal.id }

          expect(response).to have_http_status(:ok)
          jobs = controller.instance_variable_get(:@sensemaker_jobs)
          expect(jobs).to include(job)
          expect(controller.instance_variable_get(:@parent_resource)).to be(nil)
        end
      end

      context "for a Poll" do
        let(:poll) { create(:poll) }
        let!(:job) { create_publishable_job_with_output(analysable_type: "Poll", analysable_id: poll.id) }

        it "returns published jobs for the poll" do
          get :index, params: { resource_type: "polls", resource_id: poll.id }

          expect(response).to have_http_status(:ok)
          jobs = controller.instance_variable_get(:@sensemaker_jobs)
          expect(jobs).to include(job)
          expect(controller.instance_variable_get(:@parent_resource)).to be(nil)
        end
      end

      context "for a Poll::Question" do
        let(:poll) { create(:poll) }
        let(:question) { create(:poll_question, poll: poll) }
        let!(:job) { create_publishable_job_with_output(analysable_type: "Poll::Question", analysable_id: question.id) }

        it "returns published jobs and loads parent poll" do
          get :index, params: { resource_type: "poll_questions", resource_id: question.id }

          expect(response).to have_http_status(:ok)
          jobs = controller.instance_variable_get(:@sensemaker_jobs)
          expect(jobs).to include(job)
          expect(controller.instance_variable_get(:@parent_resource)).to eq(poll)
        end
      end

      context "for a Legislation::Question" do
        let(:other_process) { create(:legislation_process) }
        let(:other_question) { create(:legislation_question, process: other_process) }
        let!(:other_job) { create_publishable_job_with_output(analysable_type: "Legislation::Question", analysable_id: other_question.id) }

        it "returns published jobs and loads parent poll" do
          get :index, params: { resource_type: "legislation_questions", resource_id: other_question.id }

          expect(response).to have_http_status(:ok)
          jobs = controller.instance_variable_get(:@sensemaker_jobs)
          expect(jobs).to include(other_job)
          expect(controller.instance_variable_get(:@parent_resource)).to eq(other_process)
        end
      end

      context "for a Legislation::Proposal" do
        let(:other_process) { create(:legislation_process) }
        let(:other_proposal) { create(:legislation_proposal, process: other_process) }
        let!(:other_job) { create_publishable_job_with_output(analysable_type: "Legislation::Proposal", analysable_id: other_proposal.id) }

        it "returns published jobs and loads parent process" do
          get :index, params: { resource_type: "legislation_proposals", resource_id: other_proposal.id }

          expect(response).to have_http_status(:ok)
          jobs = controller.instance_variable_get(:@sensemaker_jobs)
          expect(jobs).to include(other_job)
          expect(controller.instance_variable_get(:@parent_resource)).to eq(other_process)
        end
      end

      context "for a Legislation::QuestionOption" do
        let(:l_process) { create(:legislation_process) }
        let(:l_question) { create(:legislation_question, process: l_process) }
        let(:l_option) { create(:legislation_question_option, question: l_question) }
        let!(:l_job) { create_publishable_job_with_output(analysable_type: "Legislation::QuestionOption", analysable_id: l_option.id) }

        it "returns published jobs and loads parent process" do
          get :index, params: { resource_type: "legislation_question_options", resource_id: l_option.id }

          expect(response).to have_http_status(:ok)
          jobs = controller.instance_variable_get(:@sensemaker_jobs)
          expect(jobs).to include(l_job)
          expect(controller.instance_variable_get(:@parent_resource)).to eq(l_process)
        end
      end

      context "when resource is not found" do
        it "returns 404" do
          get :index, params: { resource_type: "debates", resource_id: 99999 }

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when only unpublished jobs exist" do
      let(:debate) { create(:debate) }
      let!(:unpublished_job) do
        job = create(:sensemaker_job, :publishable, analysable_type: "Debate", analysable_id: debate.id,
                                                    published: false)
        output_path = job.default_output_path
        FileUtils.mkdir_p(File.dirname(output_path))
        File.write(output_path, "<html><body>Test Report</body></html>")
        job
      end

      it "returns empty collection" do
        get :index, params: { resource_type: "debates", resource_id: debate.id }

        expect(response).to have_http_status(:ok)
        jobs = controller.instance_variable_get(:@sensemaker_jobs)
        expect(jobs).to be_empty
        expect(jobs).not_to include(unpublished_job)
      end
    end
  end

  describe "GET #all_proposals_index" do
    let!(:all_proposals_job) do
      create_publishable_job_with_output(analysable_type: "Proposal", analysable_id: nil)
    end
    let!(:specific_proposal_job) do
      create_publishable_job_with_output(analysable_type: "Proposal", analysable_id: create(:proposal).id)
    end

    it "returns published jobs for all proposals (nil analysable_id)" do
      get :all_proposals_index

      expect(response).to have_http_status(:ok)
      jobs = controller.instance_variable_get(:@sensemaker_jobs)
      expect(jobs).to include(all_proposals_job)
      expect(jobs).not_to include(specific_proposal_job)
      expect(controller.instance_variable_get(:@parent_resource)).to be(nil)
    end
  end

  describe "GET #budgets_index" do
    let(:budget) { create(:budget) }
    let(:budget_group) { create(:budget_group, budget: budget) }
    let!(:budget_job) do
      create_publishable_job_with_output(analysable_type: "Budget", analysable_id: budget.id)
    end
    let!(:group_job) { create_publishable_job_with_output(analysable_type: "Budget::Group", analysable_id: budget_group.id) }
    let!(:other_budget_job) do
      create_publishable_job_with_output(analysable_type: "Budget", analysable_id: create(:budget).id)
    end

    it "returns published jobs for the budget and its groups" do
      get :budgets_index, params: { budget_id: budget.id }

      expect(response).to have_http_status(:ok)
      jobs = controller.instance_variable_get(:@sensemaker_jobs)
      expect(jobs).to include(budget_job)
      expect(jobs).to include(group_job)
      expect(jobs).not_to include(other_budget_job)
      expect(controller.instance_variable_get(:@parent_resource)).to eq(budget)
    end
  end

  describe "GET #processes_index" do
    let(:legislation_process) { create(:legislation_process) }
    let(:question) { create(:legislation_question, process: legislation_process) }
    let(:first_proposal) { create(:legislation_proposal, process: legislation_process) }
    let(:option) { create(:legislation_question_option, question: question) }
    let!(:question_job) { create_publishable_job_with_output(analysable_type: "Legislation::Question", analysable_id: question.id) }
    let!(:proposal_job) { create_publishable_job_with_output(analysable_type: "Legislation::Proposal", analysable_id: first_proposal.id) }
    let!(:option_job) { create_publishable_job_with_output(analysable_type: "Legislation::QuestionOption", analysable_id: option.id) }
    let!(:other_process_job) do
      other_process = create(:legislation_process)
      create_publishable_job_with_output(analysable_type: "Legislation::Question",
                                         analysable_id: create(
:legislation_question, process: other_process
).id)
    end

    it "returns published jobs for the process and its related resources" do
      get :processes_index, params: { process_id: legislation_process.id }

      expect(response).to have_http_status(:ok)
      jobs = controller.instance_variable_get(:@sensemaker_jobs)
      expect(jobs).to include(question_job)
      expect(jobs).to include(proposal_job)
      expect(jobs).to include(option_job)
      expect(jobs).not_to include(other_process_job)
      expect(controller.instance_variable_get(:@parent_resource)).to eq(legislation_process)
    end
  end

  describe "GET #serve_report" do
    let(:debate) { create(:debate) }
    let(:job) { create_publishable_job_with_output(analysable_type: "Debate", analysable_id: debate.id) }

    context "when job is unpublished" do
      before do
        job.update!(published: false)
      end

      it "returns 302 and redirects to root path" do
        get :serve_report, params: { id: job.id }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when job exists and has output" do
      it "sends the file with correct headers" do
        get :serve_report, params: { id: job.id }

        expect(response).to have_http_status(:ok)
        expect(response.headers["Content-Type"]).to eq("text/html")
        expect(response.headers["Content-Disposition"]).to include("inline")
        expect(response.body).to include("Test Report")
      end

      it "determines correct content type for HTML files" do
        get :serve_report, params: { id: job.id }

        expect(response.headers["Content-Type"]).to eq("text/html")
      end

      it "determines correct content type for CSV files" do
        csv_path = Rails.root.join("tmp", "test-report-#{job.id}.csv").to_s
        FileUtils.mkdir_p(File.dirname(csv_path))
        File.write(csv_path, "col1,col2\nval1,val2")
        job.update!(persisted_output: csv_path)

        get :serve_report, params: { id: job.id }

        expect(response.headers["Content-Type"]).to eq("text/csv")
        FileUtils.rm_f(csv_path)
      end

      it "determines correct content type for JSON files" do
        json_path = Rails.root.join("tmp", "test-report-#{job.id}.json").to_s
        FileUtils.mkdir_p(File.dirname(json_path))
        File.write(json_path, '{"test": "data"}')
        job.update!(persisted_output: json_path)

        get :serve_report, params: { id: job.id }

        expect(response.headers["Content-Type"]).to eq("application/json")
        FileUtils.rm_f(json_path)
      end

      it "determines correct content type for TXT files" do
        txt_path = Rails.root.join("tmp", "test-report-#{job.id}.txt").to_s
        FileUtils.mkdir_p(File.dirname(txt_path))
        File.write(txt_path, "Plain text content")
        job.update!(persisted_output: txt_path)

        get :serve_report, params: { id: job.id }

        expect(response.headers["Content-Type"]).to eq("text/plain")
        FileUtils.rm_f(txt_path)
      end

      it "uses application/octet-stream for unknown file types" do
        unknown_path = Rails.root.join("tmp", "test-report-#{job.id}.unknown").to_s
        FileUtils.mkdir_p(File.dirname(unknown_path))
        File.write(unknown_path, "Unknown content")
        job.update!(persisted_output: unknown_path)

        get :serve_report, params: { id: job.id }

        expect(response.headers["Content-Type"]).to eq("application/octet-stream")
        FileUtils.rm_f(unknown_path)
      end
    end

    context "when job does not exist" do
      it "returns 404" do
        get :serve_report, params: { id: 99999 }

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when job exists but has no output" do
      before do
        FileUtils.rm_f(job.default_output_path)
      end

      it "returns 404" do
        get :serve_report, params: { id: job.id }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
