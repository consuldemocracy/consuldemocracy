require "rails_helper"

describe Admin::Sensemaker::JobRowComponent do
  let(:user) { create(:user) }
  let(:debate) { create(:debate) }
  let(:sensemaker_job) do
    create(:sensemaker_job, user: user, analysable_type: "Debate", analysable_id: debate.id)
  end
  let(:component) { Admin::Sensemaker::JobRowComponent.new(sensemaker_job) }

  describe "#initialize" do
    it "sets the job" do
      expect(component.job).to eq(sensemaker_job)
    end
  end

  describe "#css_classes" do
    context "when job is a parent job" do
      it "returns parent-job class" do
        expect(component.css_classes).to eq("job-row parent-job")
      end
    end

    context "when job is a child job" do
      let(:parent_job) { create(:sensemaker_job) }
      let(:sensemaker_job) { create(:sensemaker_job, parent_job: parent_job) }

      it "returns child-job class" do
        expect(component.css_classes).to eq("job-row child-job")
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
