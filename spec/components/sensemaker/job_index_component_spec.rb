require "rails_helper"

describe Sensemaker::JobIndexComponent do
  include Rails.application.routes.url_helpers

  let(:debate) { create(:debate, title: "Test Debate") }
  let(:jobs) { [] }
  let(:component) { Sensemaker::JobIndexComponent.new(jobs: jobs, parent_resource: parent_resource, resource: resource) }
  let(:parent_resource) { nil }
  let(:resource) { debate }

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
    context "when resource is present (takes precedence over parent)" do
      let(:poll) { create(:poll, name: "Test Poll") }
      let(:parent_resource) { poll }
      let(:question) { create(:poll_question, poll: poll, title: "Test Question") }
      let(:resource) { question }

      it "returns title with resource name" do
        render_inline component
        expect(component.page_title).to include("Test Question")
      end
    end

    context "when parent_resource is present but no resource" do
      let(:poll) { create(:poll, name: "Test Poll") }
      let(:parent_resource) { poll }
      let(:resource) { nil }

      it "returns title with parent name" do
        render_inline component
        expect(component.page_title).to include("Test Poll")
      end
    end

    context "when resource is present but no parent" do
      let(:resource) { debate }

      it "returns title with resource name" do
        render_inline component
        expect(component.page_title).to include("Test Debate")
      end
    end

    context "when neither parent_resource nor resource is present" do
      let(:resource) { nil }

      it "returns default title" do
        render_inline component
        expect(component.page_title).to eq(I18n.t("sensemaker.job_index.title"))
      end
    end
  end

  describe "#script_type_tag" do
    context "when script is single-html-build.js" do
      let(:job) { create(:sensemaker_job, script: "single-html-build.js") }

      it "returns Report" do
        render_inline component
        expect(component.script_type_tag(job)).to eq(I18n.t("sensemaker.job_index.script_type.report"))
      end
    end

    context "when script is runner.ts" do
      let(:job) { create(:sensemaker_job, script: "runner.ts") }

      it "returns Summary" do
        render_inline component
        expect(component.script_type_tag(job)).to eq(I18n.t("sensemaker.job_index.script_type.summary"))
      end
    end

    context "when script is something else" do
      let(:job) { create(:sensemaker_job, script: "other-script.js") }

      it "returns the script name" do
        render_inline component
        expect(component.script_type_tag(job)).to eq("other-script.js")
      end
    end
  end

  describe "#resource_title" do
    context "when resource has title" do
      let(:resource) { debate }

      it "returns the title" do
        expect(component.resource_title).to eq("Test Debate")
      end
    end

    context "when resource has name" do
      let(:budget) { create(:budget, name: "Test Budget") }
      let(:resource) { budget }

      it "returns the name" do
        expect(component.resource_title).to eq("Test Budget")
      end
    end

    context "when resource is nil" do
      let(:resource) { nil }

      it "returns nil" do
        expect(component.resource_title).to be(nil)
      end
    end
  end

  describe "rendering" do
    context "when jobs are present" do
      let(:job) do
        create(:sensemaker_job,
               analysable_type: "Debate",
               analysable_id: debate.id,
               script: "single-html-build.js",
               finished_at: Time.current,
               comments_analysed: 10)
      end
      let(:jobs) { [job] }

      it "renders the jobs as cards" do
        render_inline component

        expect(page).to have_content(I18n.t("sensemaker.job_index.title_with_resource",
                                            resource_name: "Test Debate"))
        expect(page).to have_link(I18n.t("sensemaker.job_index.view_report"), href: sensemaker_job_path(job))
      end
    end

    context "when job is a summary (runner.ts)" do
      let(:job) do
        create(:sensemaker_job,
               analysable_type: "Debate",
               analysable_id: debate.id,
               script: "runner.ts",
               finished_at: Time.current,
               comments_analysed: 10)
      end
      let(:jobs) { [job] }

      it "renders the jobs as cards with View Summary link" do
        render_inline component

        expect(page).to have_link(I18n.t("sensemaker.job_index.view_summary"), href: sensemaker_job_path(job))
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
