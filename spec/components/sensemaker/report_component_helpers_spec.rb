require "rails_helper"

describe Sensemaker::ReportComponentHelpers do
  include Rails.application.routes.url_helpers

  let(:debate) { create(:debate, title: "Test Debate") }
  let(:jobs) { [] }
  let(:host) { Sensemaker::JobIndexComponent.new(jobs: jobs, parent_resource: nil, resource: nil) }

  before do
    Setting["feature.sensemaker"] = true
  end

  describe "#display_title_for" do
    it "returns nil when record is nil" do
      render_inline host
      expect(host.display_title_for(nil)).to be(nil)
    end

    context "when record has title" do
      it "returns the title" do
        render_inline host
        expect(host.display_title_for(debate)).to eq("Test Debate")
      end
    end

    context "when record has name" do
      let(:budget) { create(:budget, name: "Test Budget") }

      it "returns the name" do
        render_inline host
        expect(host.display_title_for(budget)).to eq("Test Budget")
      end
    end

    context "when record has neither title nor name" do
      let(:user) { create(:user) }

      it "returns humanized class name" do
        render_inline host
        result = host.display_title_for(user)
        expect(result).to be_a(String)
        expect(result).to be_present
      end
    end
  end

  describe "#has_jobs?" do
    context "when jobs are present" do
      let(:jobs) { [create(:sensemaker_job, analysable_type: "Debate", analysable_id: debate.id)] }

      it "returns true" do
        render_inline host
        expect(host.has_jobs?).to be true
      end
    end

    context "when no jobs are present" do
      it "returns false" do
        render_inline host
        expect(host.has_jobs?).to be false
      end
    end
  end

  describe "#script_type_tag" do
    before { render_inline host }

    context "when script is single-html-build.js" do
      let(:job) { create(:sensemaker_job, script: "single-html-build.js") }

      it "returns Report translation" do
        expect(host.script_type_tag(job)).to eq(I18n.t("sensemaker.job_index.script_type.report"))
      end
    end

    context "when script is runner.ts" do
      let(:job) { create(:sensemaker_job, script: "runner.ts") }

      it "returns Summary translation" do
        expect(host.script_type_tag(job)).to eq(I18n.t("sensemaker.job_index.script_type.summary"))
      end
    end

    context "when script is something else" do
      let(:job) { create(:sensemaker_job, script: "other-script.js") }

      it "returns the script name" do
        expect(host.script_type_tag(job)).to eq("other-script.js")
      end
    end
  end

  describe "#view_job_text" do
    before { render_inline host }

    context "when script is single-html-build.js" do
      let(:job) { create(:sensemaker_job, script: "single-html-build.js") }

      it "returns view_report translation" do
        expect(host.view_job_text(job)).to eq(I18n.t("sensemaker.job_index.view_report"))
      end
    end

    context "when script is runner.ts" do
      let(:job) { create(:sensemaker_job, script: "runner.ts") }

      it "returns view_summary translation" do
        expect(host.view_job_text(job)).to eq(I18n.t("sensemaker.job_index.view_summary"))
      end
    end
  end

  describe "#analysis_type_badge_class" do
    before { render_inline host }

    it "returns badge-report for single-html-build.js" do
      job = create(:sensemaker_job, script: "single-html-build.js")
      expect(host.analysis_type_badge_class(job)).to eq("badge-report")
    end

    it "returns badge-summary for runner.ts" do
      job = create(:sensemaker_job, script: "runner.ts")
      expect(host.analysis_type_badge_class(job)).to eq("badge-summary")
    end

    it "returns badge-default for other scripts" do
      job = create(:sensemaker_job, script: "other-script.js")
      expect(host.analysis_type_badge_class(job)).to eq("badge-default")
    end
  end

  describe "#empty_message" do
    it "returns report_index.empty translation" do
      render_inline host
      expect(host.empty_message).to eq(I18n.t("sensemaker.report_index.empty"))
    end
  end

  describe "#contextual_info_title" do
    it "returns contextual_info.title translation" do
      render_inline host
      expect(host.contextual_info_title).to eq(I18n.t("sensemaker.job_index.contextual_info.title"))
    end
  end

  describe "#breadcrumb_separator" do
    it "returns breadcrumb separator translation" do
      render_inline host
      expect(host.breadcrumb_separator).to eq(I18n.t("sensemaker.job_index.breadcrumb.separator"))
    end
  end

  describe "#path_for_sensemaker_resource" do
    before { render_inline host }

    it "returns nil when resource is nil" do
      expect(host.path_for_sensemaker_resource(nil)).to be(nil)
    end

    it "returns debate path for a Debate" do
      expect(host.path_for_sensemaker_resource(debate)).to eq(debate_path(debate))
    end

    it "returns budget path for a Budget" do
      budget = create(:budget, name: "Test Budget")
      expect(host.path_for_sensemaker_resource(budget)).to eq(budget_path(budget))
    end
  end

  describe "#parent_resource_path_for" do
    before { render_inline host }

    it "returns nil when parent_resource is nil" do
      expect(host.parent_resource_path_for(nil)).to be(nil)
    end

    it "returns budget path for a Budget" do
      budget = create(:budget, name: "Test Budget")
      expect(host.parent_resource_path_for(budget)).to eq(budget_path(budget))
    end

    it "returns legislation process path for a Legislation::Process" do
      process = create(:legislation_process, title: "Test Process")
      expect(host.parent_resource_path_for(process)).to eq(legislation_process_path(process))
    end
  end

  describe "#contextual_info_type_key_for" do
    before { render_inline host }

    it "returns nil when record is nil" do
      expect(host.contextual_info_type_key_for(nil)).to be(nil)
    end

    it "returns 'debate' for a Debate" do
      expect(host.contextual_info_type_key_for(debate)).to eq("debate")
    end

    it "returns 'budget' for a Budget" do
      budget = create(:budget, name: "Test Budget")
      expect(host.contextual_info_type_key_for(budget)).to eq("budget")
    end

    it "returns 'legislation_process' for a Legislation::Process" do
      process = create(:legislation_process, title: "Test Process")
      expect(host.contextual_info_type_key_for(process)).to eq("legislation_process")
    end
  end

  describe "#this_resource_phrase_for" do
    before { render_inline host }

    it "returns nil when record is nil" do
      expect(host.this_resource_phrase_for(nil)).to be(nil)
    end

    it "returns translated phrase for a Debate" do
      expect(host.this_resource_phrase_for(debate)).to eq(
        I18n.t("sensemaker.job_index.hero_resource_types.debate")
      )
    end

    it "returns translated phrase for a Budget" do
      budget = create(:budget, name: "Test Budget")
      expect(host.this_resource_phrase_for(budget)).to eq(
        I18n.t("sensemaker.job_index.hero_resource_types.budget")
      )
    end

    it "returns generic fallback for unknown record type" do
      user = create(:user)
      expect(host.this_resource_phrase_for(user)).to eq("this user")
    end
  end
end
