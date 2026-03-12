require "rails_helper"

RSpec.describe "Machine learning" do
  let(:admin) { create(:administrator) }

  before do
    # Ensure the feature is enabled in the database
    Setting["feature.machine_learning"] = true

    # Stub the logic-level check in the ShowComponent
    allow(MachineLearning).to receive(:enabled?).and_return(true)

    login_as(admin.user)
  end

  scenario "Executing a script" do
    visit admin_machine_learning_path

    expect(page).to have_content I18n.t("admin.machine_learning.title")

    within "#scripts" do
      select I18n.t("admin.machine_learning.scripts.proposal_tags.label"), from: "script"
      click_button I18n.t("admin.machine_learning.execute_script")
    end

    expect(page).to have_content I18n.t("admin.machine_learning.notice.success")
  end

  scenario "Cancelling an active job" do
    create(:machine_learning_job,
           user: admin.user,
           started_at: 1.minute.ago,
           finished_at: nil,
           error: nil)

    visit admin_machine_learning_path

    within "#scripts" do
      accept_confirm do
        click_button I18n.t("admin.machine_learning.cancel")
      end
    end

    expect(page).to have_button I18n.t("admin.machine_learning.execute_script")
  end

  scenario "Settings tab displays generated content info" do
    create(:machine_learning_info, kind: "comments_summary")

    visit admin_machine_learning_path

    click_link I18n.t("admin.machine_learning.tab_settings")

    # Verify tab transition (Foundation JS)
    expect(page).to have_css(".tabs-title.is-active", text: I18n.t("admin.machine_learning.tab_settings"))

    within "#settings" do
      # Now that ml_info exists in the DB, this label will be visible
      expect(page).to have_content I18n.t("admin.machine_learning.output_files")
    end
  end
end
