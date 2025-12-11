require "rails_helper"

describe Admin::Sensemaker::JobShowComponent do
  let(:user) { create(:user) }
  let(:debate) { create(:debate) }
  let(:sensemaker_job) do
    create(:sensemaker_job, user: user, analysable_type: "Debate", analysable_id: debate.id)
  end
  let(:child_jobs) { [] }
  let(:component) { Admin::Sensemaker::JobShowComponent.new(sensemaker_job, child_jobs) }

  before do
    Setting["feature.sensemaker"] = true
  end

  describe "#enabled?" do
    context "when sensemaker feature is enabled" do
      it "returns true" do
        expect(component.enabled?).to be_truthy
      end
    end

    context "when sensemaker feature is disabled" do
      before do
        Setting["feature.sensemaker"] = nil
      end

      it "returns false" do
        expect(component.enabled?).to be_falsy
      end
    end
  end

  describe "rendering" do
    it "renders the component with job details" do
      render_inline(component)
      expect(page).to have_content("Sensemaker Job ##{sensemaker_job.id}")
    end

    context "when job can be downloaded" do
      let(:artefact_path) do
        File.join(Sensemaker::Paths.sensemaker_data_folder, sensemaker_job.output_file_name)
      end
      before do
        sensemaker_job.update!(
          finished_at: Time.current,
          error: nil
        )

        data_folder = Sensemaker::Paths.sensemaker_data_folder
        FileUtils.mkdir_p(data_folder)
        File.write(artefact_path, "test")
      end

      it "renders a download link for the output file" do
        render_inline(component)

        expect(page).to have_link(File.basename(artefact_path))
      end
    end

    context "when job has errors" do
      before do
        sensemaker_job.update!(
          finished_at: Time.current,
          error: "Test error message"
        )
      end

      it "renders error section" do
        render_inline(component)

        expect(page).to have_content("Error report")
      end
    end

    context "when job has child jobs" do
      let(:child_job1) { create(:sensemaker_job, parent_job: sensemaker_job) }
      let(:child_job2) { create(:sensemaker_job, parent_job: sensemaker_job) }
      let(:child_jobs) { [child_job1, child_job2] }

      it "renders prerequisite jobs section" do
        render_inline(component)

        expect(page).to have_content("Prerequisite Jobs")
        expect(page).to have_content("These jobs were created as prerequisites for this job")
        expect(page).to have_content("Job ##{child_job1.id}")
        expect(page).to have_content("Job ##{child_job2.id}")
      end
    end
  end

  describe "shared helper methods" do
    it "includes JobComponentHelpers methods" do
      expect(component).to respond_to(:job_status_class)
      expect(component).to respond_to(:analysable_title)
      expect(component).to respond_to(:has_error?)
      expect(component).to respond_to(:can_download?)
      expect(component).to respond_to(:status_text)
      expect(component).to respond_to(:parent_job?)
      expect(component).to respond_to(:parent_job)
    end
  end
end
