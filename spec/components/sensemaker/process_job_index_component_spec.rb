require "rails_helper"

describe Sensemaker::ProcessJobIndexComponent do
  include Rails.application.routes.url_helpers

  let(:process) { create(:legislation_process, title: "Test Process") }
  let(:jobs) { [] }
  let(:component) { Sensemaker::ProcessJobIndexComponent.new(jobs: jobs, process: process) }

  before do
    Setting["feature.sensemaker"] = true
  end

  describe "#has_jobs?" do
    context "when jobs are present" do
      let(:question) { create(:legislation_question, process: process, title: "Test Question") }
      let(:jobs) do
        [create(:sensemaker_job, analysable_type: "Legislation::Question", analysable_id: question.id)]
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
    it "returns the process title" do
      expect(component.parent_resource_title).to eq("Test Process")
    end
  end

  describe "#page_title" do
    it "returns title with parent name" do
      render_inline component
      expect(component.page_title).to include("Test Process")
    end
  end

  describe "rendering" do
    context "when jobs are present" do
      let(:question) { create(:legislation_question, process: process, title: "Test Question") }
      let(:jobs) do
        [create(:sensemaker_job, analysable_type: "Legislation::Question", analysable_id: question.id)]
      end

      it "renders grouped resource links with report/summary counts" do
        render_inline component

        expect(page).to have_css("h1", text: /Discover what citizens are saying/)
        expect(page).to have_content(I18n.t("sensemaker.report_index.group_titles.legislation/question"))
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
