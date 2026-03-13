require "rails_helper"

describe Sensemaker::JobCardComponent do
  include Rails.application.routes.url_helpers

  let(:job) do
    create(:sensemaker_job,
           analysable_type: "Debate",
           analysable_id: create(:debate).id,
           script: "single-html-build.js",
           finished_at: Time.current,
           comments_analysed: 5)
  end
  let(:component) { Sensemaker::JobCardComponent.new(job) }

  before do
    Setting["feature.sensemaker"] = true
  end

  describe "rendering" do
    it "renders a card with report link when job has outputs" do
      allow(job).to receive(:has_outputs?).and_return(true)
      render_inline component

      expect(page).to have_link(I18n.t("sensemaker.job_index.view_report"),
                                href: serve_report_sensemaker_job_path(job),
                                class: "report-link")
    end

    it "does not show report link when job has no outputs" do
      allow(job).to receive(:has_outputs?).and_return(false)
      render_inline component

      expect(page).not_to have_link(href: serve_report_sensemaker_job_path(job))
      expect(page).to have_content(I18n.t("sensemaker.job_index.view_report"))
    end

    context "when comments_analysed is present" do
      it "shows comments analysed count" do
        render_inline component

        expect(page).to have_content(I18n.t("sensemaker.report_view.comments_analysed_label"))
        expect(page).to have_content("5")
      end
    end

    context "when job is a summary (runner.ts)" do
      let(:job) do
        create(:sensemaker_job,
               analysable_type: "Debate",
               analysable_id: create(:debate).id,
               script: "runner.ts",
               finished_at: Time.current)
      end

      it "renders View Summary link when job has outputs" do
        allow(job).to receive(:has_outputs?).and_return(true)
        render_inline component

        expect(page).to have_link(I18n.t("sensemaker.job_index.view_summary"),
                                  href: serve_report_sensemaker_job_path(job))
      end
    end
  end
end
