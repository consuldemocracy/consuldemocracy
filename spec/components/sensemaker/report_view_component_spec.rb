require "rails_helper"

describe Sensemaker::ReportViewComponent do
  include Rails.application.routes.url_helpers

  let(:user) { create(:user) }
  let(:component) { Sensemaker::ReportViewComponent.new(sensemaker_job) }

  before do
    Setting["feature.sensemaker"] = true
  end

  def create_publishable_job_with_output(attributes = {})
    job = create(:sensemaker_job, :publishable, attributes)
    output_path = job.default_output_path
    FileUtils.mkdir_p(File.dirname(output_path))
    File.write(output_path, "<html><body>Test Report</body></html>")
    job.update!(published: true)
    job
  end

  after do
    if defined?(sensemaker_job) && sensemaker_job&.default_output_path &&
       File.exist?(sensemaker_job.default_output_path)
      FileUtils.rm_f(sensemaker_job.default_output_path)
    end
  end

  describe "rendering explanatory text" do
    context "when analysable is a Poll" do
      let(:poll) { create(:poll, name: "Test Poll") }
      let(:sensemaker_job) do
        create_publishable_job_with_output(
          analysable_type: "Poll",
          analysable_id: poll.id
        )
      end

      it "renders explanatory text with linked poll name" do
        render_inline component

        expect(page).to have_content("Test Poll")
        expect(page).to have_link("Test Poll", href: poll_path(id: poll.slug || poll.id))
        expect(page).to have_content("The comments for the poll")
      end
    end

    context "when analysable is a Debate" do
      let(:debate) { create(:debate, title: "Test Debate") }
      let(:sensemaker_job) do
        create_publishable_job_with_output(
          analysable_type: "Debate",
          analysable_id: debate.id
        )
      end

      it "renders explanatory text with linked debate title" do
        render_inline component

        expect(page).to have_content("Test Debate")
        expect(page).to have_link("Test Debate", href: polymorphic_path(debate))
        expect(page).to have_content("The comments for the debate")
      end
    end

    context "when analysable is a Proposal" do
      let(:proposal) { create(:proposal, title: "Test Proposal") }
      let(:sensemaker_job) do
        create_publishable_job_with_output(
          analysable_type: "Proposal",
          analysable_id: proposal.id
        )
      end

      it "renders explanatory text with linked proposal title" do
        render_inline component

        expect(page).to have_content("Test Proposal")
        expect(page).to have_link("Test Proposal", href: polymorphic_path(proposal))
        expect(page).to have_content("The comments for the proposal")
      end
    end

    context "when analysable is a Legislation::Question" do
      let(:process) { create(:legislation_process, title: "Test Process") }
      let(:question) { create(:legislation_question, process: process, title: "Test Question") }
      let(:sensemaker_job) do
        create_publishable_job_with_output(
          analysable_type: "Legislation::Question",
          analysable_id: question.id
        )
      end

      it "renders explanatory text with linked question title" do
        render_inline component

        expect(page).to have_content("Test Question")
        expect(page).to have_link("Test Question", href: legislation_process_question_path(process, question))
        expect(page).to have_content("The comments for the debate")
      end
    end

    context "when analysable is a Legislation::QuestionOption" do
      let(:process) { create(:legislation_process, title: "Test Process") }
      let(:question) { create(:legislation_question, process: process, title: "Test Question") }
      let(:question_option) { create(:legislation_question_option, question: question, value: "Option A") }
      let(:sensemaker_job) do
        create_publishable_job_with_output(
          analysable_type: "Legislation::QuestionOption",
          analysable_id: question_option.id
        )
      end

      it "renders explanatory text with linked question title and option value" do
        render_inline component

        expect(question).to be_present
        expect(question_option).to be_present
        expect(page).to have_content("Test Question")
        expect(page).to have_content("Option A")
        expect(page).to have_link("Test Question", href: legislation_process_question_path(process, question))
      end
    end

    context "when analysable is a Budget" do
      let(:budget) { create(:budget, name: "Test Budget") }
      let(:sensemaker_job) do
        create_publishable_job_with_output(
          analysable_type: "Budget",
          analysable_id: budget.id
        )
      end

      it "renders explanatory text with linked budget name" do
        render_inline component

        expect(page).to have_content("Test Budget")
        expect(page).to have_link("Test Budget", href: budget_path(budget))
        expect(page).to have_content("The proposed investments for the budget")
      end
    end

    context "when analysable is a Budget::Group" do
      let(:budget) { create(:budget, name: "Test Budget") }
      let(:budget_group) { create(:budget_group, budget: budget, name: "Test Group") }
      let(:sensemaker_job) do
        create_publishable_job_with_output(
          analysable_type: "Budget::Group",
          analysable_id: budget_group.id
        )
      end

      it "renders explanatory text with linked budget name (not group)" do
        render_inline component

        expect(page).to have_content("Test Group")
        expect(page).to have_link("Test Group", href: budget_path(budget))
        expect(page).to have_content("The proposed investments for the budget group")
      end
    end

    context "when analysable is a Legislation::Proposal" do
      let(:process) { create(:legislation_process, title: "Test Process") }
      let(:proposal) { create(:legislation_proposal, process: process, title: "Test Proposal") }
      let(:sensemaker_job) do
        create_publishable_job_with_output(
          analysable_type: "Legislation::Proposal",
          analysable_id: proposal.id
        )
      end

      it "renders explanatory text with linked proposal title" do
        render_inline component

        expect(page).to have_content("Test Proposal")
        expect(page).to have_link("Test Proposal", href: legislation_process_proposal_path(process, proposal))
        expect(page).to have_content("The comments for the legislation proposal")
      end
    end

    context "when analysable is All Proposals (nil analysable_id)" do
      let(:sensemaker_job) do
        create_publishable_job_with_output(
          analysable_type: "Proposal",
          analysable_id: nil
        )
      end

      it "renders explanatory text without link" do
        render_inline component

        expect(page).to have_content("all citizen proposals")
        expect(page).not_to have_link("all citizen proposals")
      end
    end

    context "when analysable is missing" do
      let(:sensemaker_job) do
        create_publishable_job_with_output(
          analysable_type: "Debate",
          analysable_id: 99999
        )
      end

      before do
        allow(sensemaker_job).to receive(:analysable).and_return(nil)
      end

      it "renders generic explanatory text" do
        render_inline component

        expect(page).to have_content("unknown")
      end
    end
  end
end
