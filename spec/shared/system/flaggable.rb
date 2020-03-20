shared_examples "flaggable" do |factory_name|
  let(:user) { create(:user) }
  let(:flaggable) { create(factory_name) }
  let(:path) { polymorphic_path(flaggable) }

  scenario "Flagging as inappropriate", :js do
    login_as(user)
    visit path

    within ".flag-content" do
      find(".icon-flag").click
      click_link "Flag as inappropriate"

      expect(page).to have_css ".flag-active"
      expect(page).to have_link "Unflag", visible: false
    end

    expect(Flag.flagged?(user, flaggable)).to be
  end

  scenario "Unflagging", :js do
    Flag.flag(user, flaggable)

    login_as(user)
    visit path

    within ".flag-content" do
      expect(page).to have_css ".flag-active"

      find(".icon-flag").click
      click_link "Unflag"

      expect(page).not_to have_css ".flag-active"
      expect(page).to have_link "Flag as inappropriate", visible: false
    end

    expect(Flag.flagged?(user, flaggable)).not_to be
  end

  scenario "Flagging and unflagging", :js do
    login_as(user)
    visit path

    within ".flag-content" do
      find(".icon-flag").click
      click_link "Flag as inappropriate"

      expect(page).to have_css ".flag-active"
      expect(Flag.flagged?(user, flaggable)).to be

      find(".icon-flag").click
      click_link "Unflag"

      expect(page).not_to have_css ".flag-active"
    end

    expect(Flag.flagged?(user, flaggable)).not_to be
  end
end
