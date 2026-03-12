require "rails_helper"

RSpec.describe Admin::MachineLearning::ShowComponent, type: :component do
  it "renders the 'Feature Disabled' message when the feature is off" do
    # Stub the component's internal enabled? method to return false
    component = Admin::MachineLearning::ShowComponent.new(MachineLearningJob.new)
    allow(component).to receive(:enabled?).and_return(false)

    render_inline(component)

    # Verify the specific 'disabled' message appears
    expect(page).to have_content(I18n.t("admin.machine_learning.feature_disabled_link"))
    # Verify the tabs do NOT appear
    expect(page).not_to have_css("#machine_learning_tabs")
  end

  it "renders the tabs and content when the feature is on" do
    component = Admin::MachineLearning::ShowComponent.new(MachineLearningJob.new)
    allow(component).to receive(:enabled?).and_return(true)

    render_inline(component)

    expect(page).to have_css("#machine_learning_tabs")
    expect(page).to have_link(I18n.t("admin.machine_learning.tab_scripts"))
  end
end
