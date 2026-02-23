require "rails_helper"

RSpec.describe Admin::MachineLearning::SettingComponent, type: :component do
  let(:setting) { create(:setting, key: "machine_learning.comments_summary") }

  it "renders the list of output files when they exist" do
    # 1. Setup the info record
    ml_info = create(:machine_learning_info, kind: "comments_summary")

    # 2. Mock the file system check in the MachineLearning module
    allow(MachineLearning).to receive(:data_output_files).and_return(
      { comments_summary: ["summary_2024.csv", "stats_2024.json"] }
    )

    render_inline(described_class.new("comments_summary"))

    # 3. Verify the files are listed as links
    expect(page).to have_link("summary_2024.csv")
    expect(page).to have_link("stats_2024.json")
    expect(page).to have_text(I18n.t("admin.machine_learning.output_files"))
  end

  it "renders a 'no content' message when no info is present" do
    # Ensure no info record exists for this kind
    MachineLearningInfo.where(kind: "comments_summary").destroy_all

    render_inline(described_class.new("comments_summary"))

    expect(page).to have_text(I18n.t("admin.machine_learning.no_content"))
    expect(page).not_to have_text(I18n.t("admin.machine_learning.output_files"))
  end
end
