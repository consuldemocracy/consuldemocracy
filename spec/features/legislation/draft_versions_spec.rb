require 'rails_helper'

feature 'Legislation Draft Versions' do

  context "See draft text page" do
    before(:each) do
      @process = create(:legislation_process)
      @draft_version_1 = create(:legislation_draft_version, process: @process, title: "Version 1", body: "Body of the first version")
      @draft_version_2 = create(:legislation_draft_version, process: @process, title: "Version 2", body: "Body of the second version")
    end

    it "shows the text body for this version" do
      visit legislation_process_draft_version_path(@process, @draft_version_1)

      expect(page).to have_content("Body of the first version")
    end

    it "switches to another version without js" do
      visit legislation_process_draft_version_path(@process, @draft_version_1)
      expect(page).to have_content("Body of the first version")

      select("Version 2")
      click_button "see"

      expect(page).to_not have_content("Body of the first version")
      expect(page).to have_content("Body of the second version")
    end

    it "switches to another version with js", :js do
      visit legislation_process_draft_version_path(@process, @draft_version_1)
      expect(page).to have_content("Body of the first version")

      select("Version 2")

      expect(page).to_not have_content("Body of the first version")
      expect(page).to have_content("Body of the second version")
    end
  end

  context "See changes page" do
    before(:each) do
      @process = create(:legislation_process)
      @draft_version_1 = create(:legislation_draft_version, process: @process, title: "Version 1", body: "Body of the first version", changelog: "Changes for first version")
      @draft_version_2 = create(:legislation_draft_version, process: @process, title: "Version 2", body: "Body of the second version", changelog: "Changes for second version")
    end

    it "shows the text body for this version" do
      visit legislation_process_draft_version_changes_path(@process, @draft_version_1)

      expect(page).to have_content("Changes for first version")
    end

    it "switches to another version without js" do
      visit legislation_process_draft_version_changes_path(@process, @draft_version_1)
      expect(page).to have_content("Changes for first version")

      select("Version 2")
      click_button "see"

      expect(page).to_not have_content("Changes for first version")
      expect(page).to have_content("Changes for second version")
    end

    it "switches to another version with js", :js do
      visit legislation_process_draft_version_changes_path(@process, @draft_version_1)
      expect(page).to have_content("Changes for first version")

      select("Version 2")

      expect(page).to_not have_content("Changes for first version")
      expect(page).to have_content("Changes for second version")
    end
  end

end
