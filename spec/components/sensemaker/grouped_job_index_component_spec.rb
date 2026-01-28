require "rails_helper"

describe Sensemaker::GroupedJobIndexComponent do
  include Rails.application.routes.url_helpers

  let(:debate) { create(:debate, title: "Test Debate") }
  let(:jobs) { [] }
  let(:component) { Sensemaker::GroupedJobIndexComponent.new(jobs: jobs, parent_resource: parent_resource) }
  let(:parent_resource) { nil }

  before do
    Setting["feature.sensemaker"] = true
  end

  describe "#has_jobs?" do
    context "when jobs are present" do
      let(:jobs) { [create(:sensemaker_job, analysable_type: "Debate", analysable_id: debate.id)] }

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

  describe "#page_title" do
    context "when parent_resource is present" do
      let(:parent_resource) { debate }

      it "returns title with parent name" do
        render_inline component
        expect(component.page_title).to include("Test Debate")
      end
    end

    context "when parent_resource is nil" do
      it "returns default title" do
        render_inline component
        expect(component.page_title).to eq(I18n.t("sensemaker.report_index.title"))
      end
    end
  end

  describe "#parent_resource_title" do
    context "when resource has title" do
      let(:parent_resource) { debate }

      it "returns the title" do
        expect(component.parent_resource_title).to eq("Test Debate")
      end
    end

    context "when resource has name" do
      let(:budget) { create(:budget, name: "Test Budget") }
      let(:parent_resource) { budget }

      it "returns the name" do
        expect(component.parent_resource_title).to eq("Test Budget")
      end
    end

    context "when resource has neither title nor name" do
      let(:parent_resource) { create(:user) }

      it "returns humanized class name" do
        result = component.parent_resource_title
        expect(result).to be_a(String)
        expect(result).to be_present
      end
    end
  end

  describe "rendering" do
    context "when jobs are present" do
      let(:jobs) { [create(:sensemaker_job, analysable_type: "Debate", analysable_id: debate.id)] }

      it "renders the jobs list" do
        render_inline component

        expect(page).to have_content(I18n.t("sensemaker.report_index.title"))
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
