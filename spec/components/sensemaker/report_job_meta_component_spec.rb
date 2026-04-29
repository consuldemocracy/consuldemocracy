require "rails_helper"

describe Sensemaker::ReportJobMetaComponent do
  include Rails.application.routes.url_helpers

  let(:debate) { create(:debate, title: "Test Debate") }
  let(:job) do
    create(:sensemaker_job,
           analysable_type: "Debate",
           analysable_id: debate.id,
           finished_at: Time.current,
           comments_analysed: 42)
  end
  let(:component) { Sensemaker::ReportJobMetaComponent.new(job) }

  before do
    Setting["feature.sensemaker"] = true
  end

  describe "#run_timestamp" do
    context "when job has finished_at" do
      it "returns formatted timestamp" do
        expect(component.run_timestamp).to be_present
        expect(component.run_timestamp).to include(Time.current.year.to_s)
      end
    end

    context "when job has no finished_at" do
      before do
        job.update(finished_at: nil)
      end

      it "returns nil" do
        expect(component.run_timestamp).to be(nil)
      end
    end
  end

  describe "#comments_analysed_count" do
    it "returns the comments_analysed count" do
      expect(component.comments_analysed_count).to eq(42)
    end

    context "when comments_analysed is nil" do
      before do
        job.update(comments_analysed: nil)
      end

      it "returns 0" do
        expect(component.comments_analysed_count).to eq(0)
      end
    end
  end

  describe "#view_report_text" do
    it "returns the translation text when rendered" do
      render_inline component
      expect(component.view_report_text).to eq(I18n.t("sensemaker.report_view.view_report"))
    end
  end

  describe "#report_url" do
    it "returns the serve report path when rendered" do
      render_inline component
      expect(component.report_url).to eq(serve_report_sensemaker_job_path(job.id))
    end
  end

  describe "rendering" do
    it "renders the view report link when job has outputs" do
      allow(job).to receive(:has_outputs?).and_return(true)
      render_inline component

      expect(page).to have_link(I18n.t("sensemaker.report_view.view_report"),
                                href: serve_report_sensemaker_job_path(job.id))
    end

    it "does not render the view report link when job has no outputs" do
      allow(job).to receive(:has_outputs?).and_return(false)
      render_inline component

      expect(page).not_to have_link(I18n.t("sensemaker.report_view.view_report"))
    end

    it "renders comments analysed count" do
      render_inline component

      expect(page).to have_content("42")
      expect(page).to have_content(I18n.t("sensemaker.report_view.comments_analysed_label"))
    end

    context "when job has finished_at" do
      it "renders run timestamp" do
        render_inline component

        expect(page).to have_content(I18n.t("sensemaker.report_view.run_timestamp_label"))
        expect(component.run_timestamp).to be_present
      end
    end

    context "when job has no finished_at" do
      before do
        job.update(finished_at: nil)
      end

      it "does not render run timestamp" do
        render_inline component

        expect(page).not_to have_content(I18n.t("sensemaker.report_view.run_timestamp_label"))
      end
    end
  end
end
