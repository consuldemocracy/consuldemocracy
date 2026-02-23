# spec/components/admin/machine_learning/scripts_component_spec.rb
require "rails_helper"

RSpec.describe Admin::MachineLearning::ScriptsComponent, type: :component do
  let(:admin_user) { create(:administrator).user }

  it "renders the execution form when the job is empty/new" do
    # Minimal mock of a new job
    job = MachineLearningJob.new

    render_inline(described_class.new(job))

    # Check for the select label and the submit button
    expect(page).to have_text(I18n.t("admin.machine_learning.select_script"))
    expect(page).to have_button(I18n.t("admin.machine_learning.execute_script"))
  end

  it "renders the working status when the job is active" do
    # Create a job that responds true to active?
    job = create(:machine_learning_job, user: admin_user, started_at: Time.current, finished_at: nil)

    render_inline(described_class.new(job))

    expect(page).to have_css(".callout.warning")
    expect(page).to have_button(I18n.t("admin.machine_learning.cancel"))
    # The form should be hidden
    expect(page).not_to have_button(I18n.t("admin.machine_learning.execute_script"))
  end

  it "renders the summary when the job is finished" do
    job = create(:machine_learning_job, :finished, script: "proposal_tags", records_processed: 10)

    render_inline(described_class.new(job))

    expect(page).to have_css(".ml-job-summary")
    expect(page).to have_text(I18n.t("admin.machine_learning.notice.success"))
  end
end
