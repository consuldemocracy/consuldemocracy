require "rails_helper"

describe "Legislation Draft Versions" do
  context "Annotations" do
    let(:user) { create(:user) }

    before { login_as user }

    scenario "Comments are disabled when allegations phase is closed" do
      travel_to "01/01/2022".to_date

      process = create(:legislation_process, allegations_start_date: "01/01/2022",
                                             allegations_end_date: "31/01/2022")

      draft = create(:legislation_draft_version, process: process)

      note = create(:legislation_annotation,
                    draft_version: draft, text: "First comment", quote: "audiam",
                    ranges: [{ "start" => "/p[3]", "startOffset" => 6, "end" => "/p[3]", "endOffset" => 11 }])

      visit legislation_process_draft_version_annotation_path(process, draft, note)

      within "#comments" do
        expect(page).to have_content "First comment"
        fill_in "Leave your comment", with: "Second comment"
        click_button "Publish comment"
      end

      within "#comments" do
        expect(page).to have_content "First comment"
        expect(page).to have_content "Second comment"
      end

      travel_to "01/02/2022".to_date

      visit legislation_process_draft_version_annotation_path(process, draft, note)

      within "#comments" do
        expect(page).to have_content "Comments are closed"
        expect(page).not_to have_content "Leave your comment"
        expect(page).not_to have_content "Publish comment"
      end

      travel_back
    end
  end
end
