require "rails_helper"

describe "Link to top" do
  scenario "is displayed if the feature is enabled" do
    Setting["feature.link_to_top"] = true

    window_height = page.evaluate_script("window.innerHeight;")
    scroll = (window_height * 20 / 100) + 1

    visit root_path
    expect(page).to have_link("Go back to the top of the page", visible: :hidden)

    execute_script "window.scrollTo(0, #{scroll})"
    expect(page.evaluate_script("window.scrollY;")).not_to eq(0)
    expect(page).to have_link("Go back to the top of the page", visible: :visible)

    click_link "Go back to the top of the page"
    expect(page.evaluate_script("window.scrollY;")).to eq(0)

    login_as(create(:administrator).user)

    visit admin_root_path
    expect(page).to have_link("Go back to the top of the page", visible: :hidden)

    execute_script "window.scrollTo(0, #{scroll})"
    expect(page).to have_link("Go back to the top of the page", visible: :visible)
    expect(page.evaluate_script("window.scrollY;")).not_to eq(0)

    click_link "Go back to the top of the page"
    expect(page.evaluate_script("window.scrollY;")).to eq(0)
  end

  scenario "is not displayed if the feature is disabled" do
    Setting["feature.link_to_top"] = false

    visit root_path

    expect(page).not_to have_link "Go back to the top of the page", visible: :all

    login_as(create(:administrator).user)
    visit admin_root_path

    expect(page).not_to have_link "Go back to the top of the page", visible: :all
  end
end
