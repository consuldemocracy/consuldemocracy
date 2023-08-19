require "rails_helper"

describe Layout::AdminLoginItemsComponent do
  it "is not rendered for anonymous users" do
    render_inline Layout::AdminLoginItemsComponent.new(nil)

    expect(page).not_to be_rendered
  end

  it "is not rendered for regular users" do
    user = create(:user, :level_two)

    render_inline Layout::AdminLoginItemsComponent.new(user)

    expect(page).not_to be_rendered
  end

  it "shows access to all places except officing to administrators" do
    user = create(:administrator).user

    render_inline Layout::AdminLoginItemsComponent.new(user)

    expect(page).to have_link "Menu"

    page.find("ul") do |menu|
      expect(menu).to have_link "Administration"
      expect(menu).to have_link "Moderation"
      expect(menu).to have_link "Valuation"
      expect(menu).to have_link "Management"
      expect(menu).to have_link "SDG content"
      expect(menu).to have_link count: 5
    end
  end

  it "shows the moderation link to moderators" do
    user = create(:moderator).user

    render_inline Layout::AdminLoginItemsComponent.new(user)

    expect(page).to have_link "Menu"

    page.find("ul") do |menu|
      expect(menu).to have_link "Moderation"
      expect(menu).to have_link count: 1
    end
  end

  it "shows the valuation link to valuators" do
    user = create(:valuator).user

    render_inline Layout::AdminLoginItemsComponent.new(user)

    expect(page).to have_link "Menu"

    page.find("ul") do |menu|
      expect(menu).to have_link "Valuation"
      expect(menu).to have_link count: 1
    end
  end

  it "shows the management link to managers" do
    user = create(:manager).user

    render_inline Layout::AdminLoginItemsComponent.new(user)

    expect(page).to have_link "Menu"

    page.find("ul") do |menu|
      expect(menu).to have_link "Management"
      expect(menu).to have_link count: 1
    end
  end

  it "shows the SDG content link to SDG managers" do
    user = create(:sdg_manager).user

    render_inline Layout::AdminLoginItemsComponent.new(user)

    expect(page).to have_link "Menu"

    page.find("ul") do |menu|
      expect(menu).to have_link "SDG content"
      expect(menu).to have_link count: 1
    end
  end

  it "does not show the SDG content link when the SDG feature is disabled" do
    Setting["feature.sdg"] = false
    user = create(:administrator).user

    render_inline Layout::AdminLoginItemsComponent.new(user)

    expect(page).to have_link "Menu"

    page.find("ul") do |menu|
      expect(menu).to have_link "Administration"
      expect(menu).to have_link "Moderation"
      expect(menu).to have_link "Valuation"
      expect(menu).to have_link "Management"
      expect(menu).to have_link count: 4
    end
  end

  it "shows the officing link to poll officers" do
    user = create(:poll_officer).user

    render_inline Layout::AdminLoginItemsComponent.new(user)

    expect(page).to have_link "Menu"

    page.find("ul") do |menu|
      expect(menu).to have_link "Polling officers"
      expect(menu).to have_link count: 1
    end
  end

  it "shows several links to users with several roles" do
    user = create(:user)
    create(:moderator, user: user)
    create(:manager, user: user)

    render_inline Layout::AdminLoginItemsComponent.new(user)

    expect(page).to have_link "Menu"

    page.find("ul") do |menu|
      expect(menu).to have_link "Moderation"
      expect(menu).to have_link "Management"
      expect(menu).to have_link count: 2
    end
  end
end
