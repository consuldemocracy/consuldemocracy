require "rails_helper"

describe Sensemaker::ReportComponent do
  include Rails.application.routes.url_helpers

  let(:debate) { create(:debate) }
  let(:component) { Sensemaker::ReportComponent.new(debate) }

  before do
    Setting["feature.sensemaker"] = true
  end

  describe "#render?" do
    context "when sensemaker feature is enabled and job exists" do
      before do
        job = create(:sensemaker_job,
                     commentable: debate,
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

    context "when sensemaker feature is disabled" do
      before do
        Setting["feature.sensemaker"] = nil
        create(:sensemaker_job, commentable: debate)
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

  describe "#report_url" do
    context "when job has output" do
      let(:job) do
        create(:sensemaker_job,
               commentable: debate,
               finished_at: Time.current,
               persisted_output: Rails.root.join("tmp", "test-report.html").to_s)
      end

      before do
        # Create the actual file so has_output? returns true
        FileUtils.mkdir_p(File.dirname(job.persisted_output))
        File.write(job.persisted_output, "<html><body>Test Report</body></html>")
      end

      after do
        FileUtils.rm_f(job.persisted_output)
      end

      it "returns the sensemaker job path" do
        render_inline component
        expect(page).to have_css("a[href='#{sensemaker_job_path(job.id)}']")
      end
    end

    context "when job has no output" do
      before do
        create(:sensemaker_job,
               commentable: debate,
               finished_at: Time.current,
               persisted_output: nil)
      end

      it "returns nil" do
        expect(component.report_url).to be(nil)
      end
    end

    context "when no job exists" do
      it "returns nil" do
        expect(component.report_url).to be(nil)
      end
    end
  end

  describe "#report_available?" do
    context "when job has output" do
      before do
        job = create(:sensemaker_job,
                     commentable: debate,
                     finished_at: Time.current,
                     persisted_output: Rails.root.join("tmp", "test-report.html").to_s)
        # Create the actual file so has_output? returns true
        FileUtils.mkdir_p(File.dirname(job.persisted_output))
        File.write(job.persisted_output, "<html><body>Test Report</body></html>")
      end

      it "returns true" do
        expect(component.report_available?).to be true
      end
    end

    context "when job has no output" do
      before do
        create(:sensemaker_job,
               commentable: debate,
               finished_at: Time.current,
               persisted_output: nil)
      end

      it "returns false" do
        expect(component.report_available?).to be false
      end
    end
  end

  describe "rendering" do
    context "when report is available" do
      before do
        job = create(:sensemaker_job,
                     commentable: debate,
                     finished_at: Time.current,
                     persisted_output: Rails.root.join("tmp", "test-report.html").to_s)
        FileUtils.mkdir_p(File.dirname(job.persisted_output))
        File.write(job.persisted_output, "<html><body>Test Report</body></html>")
      end

      it "renders the view report link" do
        render_inline component

        expect(page).to have_link("View Report", href: sensemaker_job_path(Sensemaker::Job.last.id))
      end
    end

    context "when no report is available" do
      it "does not render the view report link" do
        render_inline component

        expect(page).not_to have_link("View Report")
      end
    end
  end
end
