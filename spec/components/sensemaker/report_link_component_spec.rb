require "rails_helper"

describe Sensemaker::ReportLinkComponent do
  include Rails.application.routes.url_helpers

  let(:debate) { create(:debate) }
  let(:component) { Sensemaker::ReportLinkComponent.new(debate) }

  before do
    Setting["feature.sensemaker"] = true
  end

  describe "#render?" do
    context "when sensemaker feature is enabled and job exists" do
      before do
        job = create(:sensemaker_job,
                     analysable_type: "Debate",
                     analysable_id: debate.id,
                     finished_at: Time.current,
                     persisted_output: Rails.root.join("tmp", "test-report.html").to_s)
        FileUtils.mkdir_p(File.dirname(job.persisted_output))
        File.write(job.persisted_output, "<html><body>Test Report</body></html>")
      end

      after do
        test_file = Rails.root.join("tmp", "test-report.html")
        FileUtils.rm_f(test_file)
      end

      it "returns true" do
        expect(component.render?).to be true
      end
    end

    context "when sensemaker feature is enabled and but job is unpublished" do
      before do
        create(:sensemaker_job, :unpublished, analysable_type: "Debate", analysable_id: debate.id)
      end

      it "returns false" do
        expect(component.render?).to be false
      end
    end

    context "when sensemaker feature is disabled" do
      before do
        Setting["feature.sensemaker"] = nil
        create(:sensemaker_job, analysable_type: "Debate", analysable_id: debate.id)
      end

      it "returns false" do
        expect(component.render?).to be_falsy
      end
    end

    context "when no job exists" do
      it "returns false" do
        expect(component.render?).to be false
      end
    end
  end

  describe "rendering" do
    context "when report is available" do
      before do
        job = create(:sensemaker_job,
                     analysable_type: "Debate",
                     analysable_id: debate.id,
                     finished_at: Time.current,
                     persisted_output: Rails.root.join("tmp", "test-report.html").to_s)
        FileUtils.mkdir_p(File.dirname(job.persisted_output))
        File.write(job.persisted_output, "<html><body>Test Report</body></html>")
      end

      it "renders the view report link" do
        render_inline component

        expect(page).to have_link("View analysis", href: sensemaker_job_path(Sensemaker::Job.last.id))
      end
    end

    context "when no report is available" do
      it "does not render the view report link" do
        render_inline component

        expect(page).not_to have_link("View analysis")
      end
    end
  end
end
