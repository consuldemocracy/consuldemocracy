require "rails_helper"

describe Sensemaker::BudgetJobIndexComponent do
  include Rails.application.routes.url_helpers

  let(:budget) { create(:budget, name: "Test Budget") }
  let(:jobs) { [] }
  let(:component) { Sensemaker::BudgetJobIndexComponent.new(jobs: jobs, budget: budget) }

  before do
    Setting["feature.sensemaker"] = true
  end

  describe "#has_jobs?" do
    context "when jobs are present" do
      let(:jobs) do
        [create(:sensemaker_job, analysable_type: "Budget", analysable_id: budget.id)]
      end

      it "returns true" do
        expect(component.has_jobs?).to be true
      end
    end

    context "when no jobs are present" do
      it "returns false" do
        expect(component.has_jobs?).to be false
      end
    end
  end

  describe "#parent_resource_title" do
    it "returns the budget name" do
      expect(component.parent_resource_title).to eq("Test Budget")
    end
  end

  describe "#page_title" do
    it "returns title with parent name" do
      render_inline component
      expect(component.page_title).to include("Test Budget")
    end
  end

  describe "rendering" do
    context "when jobs are present" do
      let(:job) do
        create(:sensemaker_job,
               analysable_type: "Budget",
               analysable_id: budget.id,
               script: "single-html-build.js",
               finished_at: Time.current)
      end
      let(:jobs) { [job] }

      it "renders the jobs as cards in a grouped section" do
        render_inline component

        expect(page).to have_css("h1", text: /Discover what citizens are saying/)
        expect(page).to have_link(I18n.t("sensemaker.job_index.view_report"),
                                  href: serve_report_sensemaker_job_path(job))
      end
    end

    context "when no jobs are present" do
      it "renders empty message" do
        render_inline component

        expect(page).to have_content(I18n.t("sensemaker.report_index.empty"))
      end
    end
  end
end
