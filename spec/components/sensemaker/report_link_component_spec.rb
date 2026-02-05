require "rails_helper"

describe Sensemaker::ReportLinkComponent do
  include Rails.application.routes.url_helpers

  let(:debate) { create(:debate) }
  let(:component) { Sensemaker::ReportLinkComponent.new(debate) }

  before do
    Setting["feature.sensemaker"] = true
  end

  describe "#render?" do
    context "when sensemaker feature is enabled and job exists for a resource" do
      let(:persisted_output) { Rails.root.join("tmp", "test-report.html").to_s }

      before do
        FileUtils.mkdir_p(File.dirname(persisted_output))
        File.write(persisted_output, "<html><body>Test Report</body></html>")
        job = create(:sensemaker_job,
                     analysable_type: "Debate",
                     analysable_id: debate.id,
                     script: "single-html-build.js",
                     finished_at: Time.current,
                     error: nil,
                     persisted_output: persisted_output,
                     published: false)
        job.update!(published: true)
      end

      after do
        FileUtils.rm_f(persisted_output)
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

    context "when analysable_resource is Proposal and published job(s) exists" do
      let(:all_proposals_component) { Sensemaker::ReportLinkComponent.new(Proposal) }
      let(:persisted_output) { Rails.root.join("tmp", "test-report-all-proposals.html").to_s }

      before do
        FileUtils.mkdir_p(File.dirname(persisted_output))
        File.write(persisted_output, "<html><body>All Proposals Report</body></html>")
        create(:sensemaker_job,
               analysable_type: "Proposal",
               analysable_id: nil,
               script: "single-html-build.js",
               finished_at: Time.current,
               error: nil,
               persisted_output: persisted_output,
               published: false).update!(published: true)
      end

      after do
        FileUtils.rm_f(persisted_output)
      end

      it "returns true" do
        expect(all_proposals_component.render?).to be true
      end
    end

    context "when analysable_resource is Proposal and no published job(s) exist" do
      let(:all_proposals_component) { Sensemaker::ReportLinkComponent.new(Proposal) }

      it "returns false" do
        expect(all_proposals_component.render?).to be false
      end
    end
  end

  describe "rendering" do
    context "when report is available" do
      let(:persisted_output) { Rails.root.join("tmp", "test-report.html").to_s }

      before do
        FileUtils.mkdir_p(File.dirname(persisted_output))
        File.write(persisted_output, "<html><body>Test Report</body></html>")
        job = create(:sensemaker_job,
                     analysable_type: "Debate",
                     analysable_id: debate.id,
                     script: "single-html-build.js",
                     finished_at: Time.current,
                     error: nil,
                     persisted_output: persisted_output,
                     published: false)
        job.update!(published: true)
      end

      after do
        FileUtils.rm_f(persisted_output)
      end

      it "renders the view report link" do
        render_inline component

        expect(page).to have_link("View analysis",
                                  href: sensemaker_resource_jobs_path(resource_type: "debates",
                                                                      resource_id: debate.id))
      end
    end

    context "when no report is available" do
      it "does not render the view report link" do
        render_inline component

        expect(page).not_to have_link("View analysis")
      end
    end

    context "when report is available for All proposals (Proposal class)" do
      let(:all_proposals_component) { Sensemaker::ReportLinkComponent.new(Proposal) }
      let(:persisted_output) { Rails.root.join("tmp", "test-report-all-proposals-render.html").to_s }

      before do
        FileUtils.mkdir_p(File.dirname(persisted_output))
        File.write(persisted_output, "<html><body>All Proposals Report</body></html>")
        create(:sensemaker_job,
               analysable_type: "Proposal",
               analysable_id: nil,
               script: "single-html-build.js",
               finished_at: Time.current,
               error: nil,
               persisted_output: persisted_output,
               published: false).update!(published: true)
      end

      after do
        FileUtils.rm_f(persisted_output)
      end

      it "renders the view report link pointing to all proposals jobs index" do
        render_inline all_proposals_component

        expect(page).to have_link("View analysis", href: sensemaker_all_proposals_jobs_path)
      end

      it "uses the all-proposals analysis description" do
        render_inline all_proposals_component

        expect(page).to have_content("We've analysed these proposals")
      end
    end
  end
end
